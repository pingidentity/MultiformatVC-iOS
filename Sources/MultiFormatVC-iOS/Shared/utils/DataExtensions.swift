/**
 *
 * DataExtensions.swift
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

public extension Data {
    func base64URLEncodedString() -> String {
        let base64Encoded = self.base64EncodedString()
        let urlSafeBase64 = base64Encoded
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .trimmingCharacters(in: .whitespaces)
        if let range = urlSafeBase64.range(of: "={1,2}$", options: .regularExpression) {
            return String(urlSafeBase64[..<range.lowerBound])
        }
                
        return urlSafeBase64
    }
}
