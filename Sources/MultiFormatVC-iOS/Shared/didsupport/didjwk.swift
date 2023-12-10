/**
 *
 * didjwk.swift
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

public class didjwk: didmethod {
    public var publicKey: Any
    
    public init(from identifier:String) throws {
        let jsonDecoder = JSONDecoder()
        
        let parts:[String.SubSequence] = identifier.split(separator: ":")
        if let jwkData = String(parts[2]).base64urlToBase64().data(using: .utf8) {
            let jwkWrapper = try jsonDecoder.decode(jwk_base.self, from: jwkData)
            if let jwk = jwkWrapper.jwk {
                self.publicKey = try jwk.getPublicKey()
            } else {
                throw GeneralError.DecodingError // TODO: specific errors
            }
        } else {
            throw GeneralError.DecodingError
        }
    }
}
