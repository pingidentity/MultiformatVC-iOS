/**
 *
 * jwk_base.swift
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

public struct jwk_base:Codable {
    internal let keyType:String
    internal let keyId: String?
    internal let jwk:jwk_type?
    
    private enum CodingKeys: String, CodingKey {
        case keyType = "kty", keyId = "kid"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.keyType = try container.decode(String.self, forKey: .keyType)
        self.keyId = try container.decodeIfPresent(String.self, forKey: .keyId)
        
        switch keyType.lowercased() {
        case "okp":
            self.jwk = try jwk_okp(from: decoder)
        case "ec":
            self.jwk = try jwk_ec(from: decoder)
        case "rsa":
            self.jwk = nil
        default:
            self.jwk = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch jwk {
        case let jwk as jwk_ec:
            try jwk.encode(to: encoder)
        case let jwk as jwk_okp:
            try jwk.encode(to: encoder)
        default:
            print("Don't recognized the ")
        }
    }
}
