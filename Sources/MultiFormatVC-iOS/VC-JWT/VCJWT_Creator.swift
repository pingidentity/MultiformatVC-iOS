/**
 *
 * VCJWT_Creator.swift
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

public class VCJWT_Creator {
    public var payload:vc_jwt_payload
    public var header:jwt_header
    
    public var signer:((Data) throws -> Data)!
    
    public init(algorithm: String, keyId: String) {
        self.payload = vc_jwt_payload()
        self.header = jwt_header(type: "JWT", algorithm: algorithm, keyId: keyId)
    }
    
    public func setCredentialSubject(_ credentialSubject: [String: Any]) {
        if self.payload.vc == nil {
            self.payload.vc = vc_claim()
        }
        var subject:[String: MixedCodable] = [:]
        for (key, value) in credentialSubject {
            subject[key] = MixedCodable(value: value)
        }
        self.payload.vc?.credentialSubject = subject
    }
    
    public func addToCredentialSubject(key: String, value: Any) {
        if self.payload.vc == nil {
            self.payload.vc = vc_claim()
        }
        self.payload.vc?.credentialSubject![key] = MixedCodable(value: value)
    }
    
    public func setCredentialTypes(types: [String]) {
        if self.payload.vc == nil {
            self.payload.vc = vc_claim()
        }
        if self.payload.vc?.type == nil {
            self.payload.vc?.type = []
        }
        self.payload.vc?.type?.append(contentsOf: types)
    }
    
    public func setCredentialType(type: String) {
        setCredentialTypes(types: [type])
    }
    
    public func getEncodedVC() throws -> String {
        guard let _ = payload.jwtId,
              let _ = payload.issuer,
              let _ = payload.subject else {
            throw GeneralError.DecodingError // TODO: Fix this
        }
        
        let jsonEncoder = JSONEncoder()

        if payload.issuedAt == nil {
            payload.issuedAt = UInt64(Date().timeIntervalSince1970)
        }
        
        let headerJSON = try jsonEncoder.encode(self.header)
        let payloadJSON = try jsonEncoder.encode(self.payload)
        
        let headerB64 = headerJSON.base64URLEncodedString()
        let payloadB64 = payloadJSON.base64URLEncodedString()
        
        guard let dataToSign = (headerB64 + "." + payloadB64).data(using: .utf8) else {
            throw GeneralError.EncodingError
        }
        
        let encodedVC = headerB64 + "." + payloadB64
        
        if let signer = signer {
            let signedData = try signer(dataToSign)
            return encodedVC + "." + signedData.base64URLEncodedString()
        }
        
        return encodedVC
    }
}
