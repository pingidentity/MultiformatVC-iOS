/**
 *
 * SDJWT.swift
 *
 * MultiFormatVC-iOS
 * 2023
 *
 * Copyright: Ping Identity
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import CryptoKit

public class SDJWT {
    public var jwtHeader:jwt_header!
    public var payload:sd_jwt_payload!
    public var disclosuresB64:[String] = []
    public var disclosures:[String: Any] = [:]
    
    private let headerB64:String!
    private let payloadB64:String!
    private let signatureB64:String!
        
    public init(from encodedVC: String) throws {
        let vcParts:[String.SubSequence] = encodedVC.split(separator: ".")
        guard vcParts.count >= 3 else {
            throw VerifiableCredentialValidationError.EncodedCredentialShouldContainAtLeastTwoParts
        }
        self.headerB64 = String(vcParts[0])
        self.payloadB64 = String(vcParts[1])
        let signatureAndDisclosures = String(vcParts[2])
        
        let disclosures = signatureAndDisclosures.split(separator: "~").map({String($0)})
        self.signatureB64 = disclosures[0]
        self.disclosuresB64 = disclosures.dropFirst().map({String($0)})
                
        let decoder = JSONDecoder()
        
        guard let headerb64Data = headerB64.base64urlToBase64().data(using: .utf8),
              let payloadb64Data = payloadB64.base64urlToBase64().data(using: .utf8),
              let decodedHeader = Data(base64Encoded: headerb64Data),
              let decodedPayload = Data(base64Encoded: payloadb64Data) else {
            throw VerifiableCredentialValidationError.GeneralDecodingError
        }
        
        self.jwtHeader = try decoder.decode(jwt_header.self, from: decodedHeader)
        self.payload = try decoder.decode(sd_jwt_payload.self, from: decodedPayload)
        
        try decodeDisclosures()
        print("Init Complete")
    }
    
    private func decodeDisclosures() throws {
        let jsonDecoder = JSONDecoder()
        self.disclosures = [:]
        for disclosureB64 in self.disclosuresB64 {
            guard let disclosureB64Data = disclosureB64.base64urlToBase64().data(using: .utf8),
                  let decodedDisclosure = Data(base64Encoded: disclosureB64Data) else {
                throw VerifiableCredentialValidationError.GeneralDecodingError
            }
            do {
                let disclosureArray = try jsonDecoder.decode([MixedCodable].self, from: decodedDisclosure)
                if case .string(let key) = disclosureArray[1],
                   case .string(let value) = disclosureArray[2] {
                    self.disclosures[key] = value
                } else if case .string(let key) = disclosureArray[1],
                          case .stringArray(let value) = disclosureArray[2] {
                    self.disclosures[key] = value
                } else if case .string(let key) = disclosureArray[1],
                          case .stringStringMap(let value) = disclosureArray[2] {
                    self.disclosures[key] = value
                } else if case .string(let key) = disclosureArray[1],
                          case .int(let value) = disclosureArray[2] {
                    self.disclosures[key] = value
                } else if case .string(let key) = disclosureArray[1],
                          case .bool(let value) = disclosureArray[2] {
                    self.disclosures[key] = value
                }
            } catch DecodingError.typeMismatch {
                print("Error decoding disclosure: \(disclosureB64)")
                throw GeneralError.DecodingError
            }
        }
    }
    
    public func verifySignature(verifier: ((Data, Data) -> Bool)) throws -> Bool {
        if let signatureb64Data = self.signatureB64.base64urlToBase64().data(using: .utf8),
           let signatureData = Data(base64Encoded: signatureb64Data),
           let signedData = (self.headerB64 + "." + self.payloadB64).data(using: .utf8) {
            return verifier(signatureData, signedData)
        }
        return false
    }
    
    public func verifySDContent() -> [String] {
        guard let sd = self.payload._sd else {
            return ["No _sd found in SD-JWT payload"]
        }
        var errors:[String] = []
        for disclosure in disclosuresB64 {
            if let disclosureData = disclosure.data(using: .utf8) {
                let disclosureDigest = SHA256.hash(data: disclosureData)
                if !sd.contains(Data(disclosureDigest).base64URLEncodedString()) {
                    if let disclosureBase64Decoded = Data(base64Encoded: disclosure) {
                        let disclosureString = String(decoding: disclosureBase64Decoded, as: UTF8.self)
                        errors.append("Disclosure \(disclosureString) not contained in _sd array in the SD-JWT")
                    } else {
                        errors.append("Disclosure is not a base64 encoded value: \(disclosure)")
                    }
                }
            }
        }
        return errors
    }
    
    var description: String {
        return "Verifiable Credential: \n" +
            "JWS: \(headerB64!).\(payloadB64!).\(signatureB64!)\n" +
            "Disclosures: \(disclosuresB64)"
    }
}
