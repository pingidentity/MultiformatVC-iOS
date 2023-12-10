/**
 *
 * jwt_header.swift
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

public struct jwt_header:Codable {
    internal let type:String?
    internal let algorithm:String?
    internal let keyId:String?
    
    internal enum CodingKeys: String, CodingKey {
        case type = "typ", algorithm = "alg", keyId = "kid"
    }
    
    public init(algorithm:String, keyId:String) {
        self.type = "vc+sd-jwt"
        self.algorithm = algorithm
        self.keyId = keyId
    }

    public init(type: String, algorithm:String, keyId:String) {
        self.type = type
        self.algorithm = algorithm
        self.keyId = keyId
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.keyId = try container.decodeIfPresent(String.self, forKey: .keyId)
        self.algorithm = try container.decodeIfPresent(String.self, forKey: .algorithm)
    }
}
