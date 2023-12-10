/**
 *
 * SandboxTests.swift
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

import XCTest
@testable import MultiFormatVC_iOS


final class SandboxTests: XCTestCase {
    func testEncodingDecoding() throws {
        let jsonData = """
            ["Qg_O64zqAxe412a108iroA", "address", {"street_address": "123 Main St", "locality": "Anytown", "region": "Anystate", "country": "US"}]
        """.data(using: .utf8)!
        do {
            let decodedArray = try JSONDecoder().decode([MixedCodable].self, from:jsonData)
            // Here, you have your Array
            print(decodedArray) // [.string("A"), .int(1), .string("A1"), .int(13), .int(15), .int(2), .string("B")]

            // If you want to get elements from this Array, you might do something like below
            decodedArray.forEach({ (value) in
                if case .string(let integer) = value {
                    print(integer) // "A", "A1", "B"
                }
                if case .int(let int) = value {
                    print(int) // 1, 13, 15, 2
                }
                if case .stringStringMap(let stringStringMap) = value {
                    print("String:String Map \(stringStringMap)") // 1, 13, 15, 2
                }

            })
            if case .stringStringMap(let map) = decodedArray[2] {
                print(map, map.keys, map.values)
            }
        } catch {
            print(error)
        }
    }
    
}
