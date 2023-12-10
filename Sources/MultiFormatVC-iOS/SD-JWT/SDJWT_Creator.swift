/**
 *
 * SDJWT_Creator.swift
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

public class SDJWT_Creator {
    private let SECURE_RANDOM_ARRAY_LENGTH = 32
    
    public var payload:sd_jwt_payload
    public var header:jwt_header
    
    public enum HashAlgorithm {
        case SHA_256, SHA_384, SHA_512
        
        func digest(data: Data) -> Data {
            switch self {
            case .SHA_256:
                return Data(SHA256.hash(data: data))
            case .SHA_384:
                return Data(SHA384.hash(data: data))
            case .SHA_512:
                return Data(SHA512.hash(data: data))
            }
        }
        
        var name:String {
            switch self {
            case .SHA_256:
                return "sha-256"
            case .SHA_384:
                return "sha-384"
            case .SHA_512:
                return "sha-512"
            }
        }
    }
    
    public var signer:((Data) throws -> Data)!

    private var credentialSubject:[String:Any]?
    
    private var _disclosures:[(String, String, MixedCodable, String)] = []
        
    public init(algorithm: String, keyId: String) {
        self.payload = sd_jwt_payload()
        self.header = jwt_header(type: "vc+sd-jwt", algorithm: algorithm, keyId: keyId)
    }
    
    public func addToCredentialSubject(key: String, value: Any) {
        if self.credentialSubject == nil {
            self.credentialSubject = [:]
        }
        self.credentialSubject?[key] = value
    }
    
    public func setCredentialSubject(_ credentialSubject:[String:Any]) {
        self.credentialSubject = credentialSubject
    }
    
    public func setCredentialType(type: String) {
        self.payload.type = type
    }
            
    public func getEncodedVC(hashAlgorithm: HashAlgorithm = HashAlgorithm.SHA_256, decoyDigests: UInt8 = 0) throws -> String {
        guard let _ = payload.jwtId,
              let _ = payload.issuer,
              let _ = payload.subject else {
            throw CredentialWriterError.RequiredCredentialClaimsMissing
        }
        
        guard let _ = self.credentialSubject else {
            // TODO: Maybe this check is not required
            throw CredentialWriterError.NeedAtLeastOneDisclosure
        }
        
        self.payload._sd_alg = hashAlgorithm.name

        let jsonEncoder = JSONEncoder()

        try buildSDClaims(hashAlgorithm: hashAlgorithm, decoyDigests: decoyDigests)
                
        let headerJSON = try jsonEncoder.encode(self.header)
        let payloadJSON = try jsonEncoder.encode(self.payload)
        
        let headerB64 = headerJSON.base64URLEncodedString()
        let payloadB64 = payloadJSON.base64URLEncodedString()
        
        guard let dataToSign = (headerB64 + "." + payloadB64).data(using: .utf8) else {
            throw GeneralError.EncodingError
        }
        
        let disclosures = _disclosures.map({$0.3})
        
        var signatureComponent = ""

        if let signer = signer {
            let signedData = try signer(dataToSign)
            signatureComponent = "." + signedData.base64URLEncodedString()
        }
        let encodedSDJWT = headerB64 + "." + payloadB64 + signatureComponent + "~" + disclosures.joined(separator: "~")
        
        return encodedSDJWT
    }
    
    internal func buildSDClaims(hashAlgorithm: HashAlgorithm = HashAlgorithm.SHA_256, decoyDigests: UInt8 = 0) throws {
        try buildDisclosures()
        var _sd:[String] = []
        for disclosure in _disclosures {
            if let disclosureData = disclosure.3.data(using: .utf8) {
                let disclosureDigest = hashAlgorithm.digest(data: disclosureData)
                _sd.append(disclosureDigest.base64URLEncodedString())
            } else {
                throw GeneralError.EncodingError
            }
        }
        
        // Create Decoy Digests
        for _ in 0..<decoyDigests {
            if let randomBytes = secureRandomBytes(count: SECURE_RANDOM_ARRAY_LENGTH) {
                let decoyData = Data(bytes: randomBytes, count: SECURE_RANDOM_ARRAY_LENGTH)
                let decoyDisclosureDigest = hashAlgorithm.digest(data: decoyData)
                _sd.append(decoyDisclosureDigest.base64URLEncodedString())
            } else {
                throw GeneralError.EncodingError
            }
        }
        
        // Shuffle the decoy digests and the real content
        _sd.shuffle()
        self.payload._sd = _sd
    }
    
    private func buildDisclosures() throws {
        guard let _credentialSubject = self.credentialSubject else {
            return
        }
        self._disclosures = []
        let encoder = JSONEncoder()
        for (key, value) in _credentialSubject {
            if let salt = base64EncodedSecureRandom(length: 32) {
                let disclosureArray:[MixedCodable] = [ MixedCodable.string(salt), MixedCodable.string(key), MixedCodable(value: value) ]
                let disclosure = try encoder.encode(disclosureArray)
                let disclosureB64 = disclosure.base64URLEncodedString()
                self._disclosures.append((salt, key, disclosureArray[2], disclosureB64))
            }
        }
    }
    
    public func getDisclosures(filteredBy: [String] = []) -> [String] {
        if filteredBy.isEmpty {
            return _disclosures.map({$0.3})
        }
        
        var filteredDisclosures:[String] = []
        for _disclosure in _disclosures {
            if (filteredBy.contains(_disclosure.1)) {
                filteredDisclosures.append(_disclosure.3)
            }
        }
        return filteredDisclosures
    }
}
