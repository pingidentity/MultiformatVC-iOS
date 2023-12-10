/**
 *
 * vc_jwt_payload.swift
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

public struct vc_jwt_payload:Codable {
    internal var jwtId:String?
    internal var subject:String?
    internal var issuer:String?
    internal var issuedAt:UInt64?
    internal var expiry:UInt64?
    internal var notBefore:UInt64?
    internal var vc:vc_claim?
    
    private enum CodingKeys: String, CodingKey {
        case jwtId = "jti", subject = "sub", issuer = "iss", issuedAt = "iat", expiry = "exp", notBefore = "nbf", vc
    }
    
    public init() {
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jwtId = try container.decodeIfPresent(String.self, forKey: .jwtId)
        self.subject = try container.decodeIfPresent(String.self, forKey: .subject)
        self.issuer = try container.decodeIfPresent(String.self, forKey: .issuer)
        self.expiry = try container.decodeIfPresent(UInt64.self, forKey: .expiry)
        self.notBefore = try container.decodeIfPresent(UInt64.self, forKey: .notBefore)
        self.vc = try container.decodeIfPresent(vc_claim.self, forKey: .vc)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(jwtId, forKey: .jwtId)
        try container.encodeIfPresent(subject, forKey: .subject)
        try container.encodeIfPresent(issuer, forKey: .issuer)
        try container.encodeIfPresent(expiry, forKey: .expiry)
        try container.encodeIfPresent(notBefore, forKey: .notBefore)
        try container.encodeIfPresent(vc, forKey: .vc)
    }
}
