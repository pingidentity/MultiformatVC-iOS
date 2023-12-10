/**
 *
 * sd_cnf.swift
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

public struct sd_cnf:Codable {
    internal let jwk:jwk_type?
    
    public enum CodingKeys: String, CodingKey {
        case jwk
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let jwkBase = try container.decodeIfPresent(jwk_base.self, forKey: .jwk) {
            self.jwk = jwkBase.jwk
        } else {
            throw GeneralError.DecodingError
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch jwk {
        case let jwk as jwk_ec:
            try container.encodeIfPresent(jwk, forKey: .jwk)
        case let jwk as jwk_okp:
            try container.encodeIfPresent(jwk, forKey: .jwk)
        default:
            print("Don't recognized the JWK type")
        }
    }
}
