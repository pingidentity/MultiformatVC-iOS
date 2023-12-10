/**
 *
 * VCJWT.swift
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

public class VCJWT {
    private var jwtHeader:jwt_header
    private var jwtPayload:vc_jwt_payload
    
    private let encodedVC:String
    
    public var checkSignatureCallback:((_ signature: Data, _ data: Data)->Bool)!
    
    public init(from encodedVC: String) throws {
        self.encodedVC = encodedVC
        
        let vcParts:[String.SubSequence] = encodedVC.split(separator: ".")
        guard vcParts.count >= 2 else {
            throw VerifiableCredentialValidationError.EncodedCredentialShouldContainAtLeastTwoParts
        }
        let headerB64 = String(vcParts[0])
        let payloadB64 = String(vcParts[1])
                        
        let decoder = JSONDecoder()
        
        guard let headerb64Data = headerB64.base64urlToBase64().data(using: .utf8),
              let payloadb64Data = payloadB64.base64urlToBase64().data(using: .utf8),
              let decodedHeader = Data(base64Encoded: headerb64Data),
              let decodedPayload = Data(base64Encoded: payloadb64Data) else {
            throw VerifiableCredentialValidationError.GeneralDecodingError
        }
        
        self.jwtHeader = try decoder.decode(jwt_header.self, from: decodedHeader)
        self.jwtPayload = try decoder.decode(vc_jwt_payload.self, from: decodedPayload)
    }
    
    public func getCredentialSubject() -> [String:Any]? {
        var subject:[String:Any] = [:]
        if let vc = self.jwtPayload.vc,
           let credentialSubject = vc.credentialSubject {
            for (key, value) in credentialSubject {
                subject[key] = value.value
            }
        }
        return subject
    }
    
    public func getIssuer() -> String? {
        return self.jwtPayload.issuer
    }
    
    public func validateSignature() throws -> Bool {
        guard let checkSignatureCallback = self.checkSignatureCallback else {
            return false
        }
        
        let vcParts:[String.SubSequence] = encodedVC.split(separator: ".")
        guard vcParts.count == 3 else {
            throw VerifiableCredentialValidationError.SignatureVerificationRequiresThreeParts
        }
        let headerB64 = String(vcParts[0])
        let payloadB64 = String(vcParts[1])
        let signatureB64 = String(vcParts[2])
        
        if let signatureb64Data = signatureB64.base64urlToBase64().data(using: .utf8),
           let signatureData = Data(base64Encoded: signatureb64Data),
           let signedData = (headerB64 + "." + payloadB64).data(using: .utf8) {
            return checkSignatureCallback(signatureData, signedData)
        }
        return false
    }
}

/*
 {
   "kid" : "did:ion:XXX#key-1",
   "typ" : "JWT",
   "alg" : "EdDSA"
 }.
 {
   "sub" : "did:ion:XXX",
   "nbf" : 1674772063,
   "iss" : "did:ion:XXX",
   "iat" : 1674772063,
   "vc" : {
     "credentialSubject" : {
       "preferredLanguage" : "en-US",
       "mail" : "pat.smith@example.com",
       "displayName" : "Pat Smith",
       "surname" : "Smith",
       "givenName" : "Pat",
       "jobTitle" : "Worker"
     },
     "type" : [ "VerifiableCredential", "VerifiedEmployee" ],
     "@context" : [ "https://www.w3.org/2018/credentials/v1" ],
     "credentialStatus" : {
       "statusListIndex" : "0",
       "id" : "https://example.com/api/astatuslist/did:ion:EiBAA99TAezxKRc2wuuBnr4zzGsS2YcsOA4IPQV0KY64Xg/1#0",
       "type" : "RevocationList2021Status",
       "statusListCredential" : "https://example.com/api/astatuslist/did:ion:EiBAA99TAezxKRc2wuuBnr4zzGsS2YcsOA4IPQV0KY64Xg/1"
     }
   },
   "jti" : "b8052f9c-4f8c-4330-bbc1-4033b8ee5d6b"
 }.
 */
