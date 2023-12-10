/**
 *
 * SecureUtils.swift
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

func secureRandomBytes(count: Int) -> [Int8]? {
    var bytes = [Int8](repeating: 0, count: count)

    if SecRandomCopyBytes(
        kSecRandomDefault,
        count,
        &bytes
    ) == errSecSuccess {
        return bytes
    } else {
      return nil
    }
}

func base64EncodedSecureRandom(length: Int) -> String? {
    // TODO: Should length translate to count?
    if let randomBytes = secureRandomBytes(count: length) {
        let data = Data(bytes: randomBytes, count: length)
        return data.base64URLEncodedString()
    }
    return nil
}

internal func makeKeyPair() -> (Curve25519.Signing.PrivateKey, Curve25519.Signing.PublicKey) {
    let privateKey =  Curve25519.Signing.PrivateKey()
    let publicKey = privateKey.publicKey;
    
    return (privateKey, publicKey)
}
