/**
 *
 * jwk_ec.swift
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

struct jwk_ec:Codable, jwk_type {
    
    let kty: String
    let kid: String?
    let x:String
    let y:String
    let crv:String
    let d:String?
    let use: String?
    let alg: String?
    
    internal enum CodingKeys : String, CodingKey {
        case kty, kid, x, y, crv, use, alg, d
    }
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.kty = try container.decode(String.self, forKey: .kty)
        self.kid = try container.decodeIfPresent(String.self, forKey: .kid)
        self.x = try container.decode(String.self, forKey: .x)
        self.y = try container.decode(String.self, forKey: .y)
        self.crv = try container.decode(String.self, forKey: .crv)
        self.alg = try container.decodeIfPresent(String.self, forKey: .alg)
        self.use = try container.decodeIfPresent(String.self, forKey: .use)
        self.d = try container.decodeIfPresent(String.self, forKey: .d)
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(kty, forKey: .kty)
        try container.encode(x, forKey: .x)
        try container.encode(y, forKey: .y)
        try container.encode(crv, forKey: .crv)
        try container.encodeIfPresent(kid, forKey: .kid)
        try container.encodeIfPresent(use, forKey: .use)
        try container.encodeIfPresent(d, forKey: .d)
        try container.encodeIfPresent(alg, forKey: .alg)
    }
    
    func getPublicKey() throws -> Any {
        guard let publicKeyDatax = Data(base64Encoded: x.base64urlToBase64()),
              let publicKeyDatay = Data(base64Encoded: y.base64urlToBase64()) else {
            throw KeyEncodingDecodingErrors.KeyDecodingGeneralError
        }
        var publicKeyData = Data(publicKeyDatax)
        publicKeyData.append(publicKeyDatay)
        switch crv.lowercased() {
        case "p-256":
            return try P256.Signing.PublicKey(rawRepresentation: publicKeyData)
        case "p-384":
            return try P384.Signing.PublicKey(rawRepresentation: publicKeyData)
        case "p-521":
            return try P521.Signing.PublicKey(rawRepresentation: publicKeyData)
        default:
            throw KeyEncodingDecodingErrors.UnrecognizedKeyCurve
        }
    }
    
    func getPrivateKey() throws -> Any? {
        guard let d = d,
              let privateKeyData = Data(base64Encoded: d.base64urlToBase64()) else {
            throw KeyEncodingDecodingErrors.KeyDecodingGeneralError
        }
        switch crv.lowercased() {
        case "p-256":
            return try P256.Signing.PrivateKey(rawRepresentation: privateKeyData)
        case "p-384":
            return try P384.Signing.PrivateKey(rawRepresentation: privateKeyData)
        case "p-521":
            return try P521.Signing.PrivateKey(rawRepresentation: privateKeyData)
        default:
            throw KeyEncodingDecodingErrors.UnrecognizedKeyCurve
        }
    }
}
