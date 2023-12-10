/**
 *
 * sd_jwt_payload.swift
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

public struct sd_jwt_payload:Codable {
    public var jwtId:String?
    public var subject:String?
    public var issuer:String?
    public var expiry:UInt64?
    public var notBefore:UInt64?
    public var type:String?
    public var issuedAt:UInt64?
    public var cnf:sd_cnf?
    public var status:vc_status?
    public var _sd:[String]?
    public var _sd_alg:String?
    
    private enum CodingKeys: String, CodingKey {
        case jwtId = "jti", subject = "sub", issuer = "iss", issuedAt = "iat", expiry = "exp", notBefore = "nbf", _sd, type, cnf, _sd_alg, status
    }
    
    public init() {
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.subject = try container.decodeIfPresent(String.self, forKey: .subject)
        self.issuer = try container.decodeIfPresent(String.self, forKey: .issuer)
        self.expiry = try container.decodeIfPresent(UInt64.self, forKey: .expiry)
        self.notBefore = try container.decodeIfPresent(UInt64.self, forKey: .notBefore)
        self.jwtId = try container.decodeIfPresent(String.self, forKey: .jwtId)
        self._sd = try container.decodeIfPresent([String].self, forKey: ._sd)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self._sd_alg = try container.decodeIfPresent(String.self, forKey: ._sd_alg)
        self.status = try container.decodeIfPresent(vc_status.self, forKey: .status)
        
        self.cnf = try container.decodeIfPresent(sd_cnf.self, forKey: .cnf)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(subject, forKey: .subject)
        try container.encodeIfPresent(issuer, forKey: .issuer)
        try container.encodeIfPresent(expiry, forKey: .expiry)
        try container.encodeIfPresent(notBefore, forKey: .notBefore)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(_sd_alg, forKey: ._sd_alg)
        try container.encodeIfPresent(_sd, forKey: ._sd)
        try container.encodeIfPresent(cnf, forKey: .cnf)
        try container.encodeIfPresent(status, forKey: .status)
    }
}
