/**
 *
 * MixedCodable.swift
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

public enum MixedCodable: Codable {
    case string(String)
    case int(Int)
    case stringArray([String])
    case stringStringMap([String:String])
    case bool(Bool)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = try .string(container.decode(String.self))
        } catch DecodingError.typeMismatch {
            do {
                self = try .int(container.decode(Int.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try .stringArray(container.decode([String].self))
                } catch DecodingError.typeMismatch {
                    do {
                        self = try .stringStringMap(container.decode([String:String].self))
                    } catch DecodingError.typeMismatch {
                        do {
                            self = try .bool(container.decode(Bool.self))
                        } catch DecodingError.typeMismatch {
                            throw DecodingError.typeMismatch(MixedCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type. Has to be String, Int, [String], or [String:String]"))
                        }
                    }
                }
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let int):
            try container.encode(int)
        case .string(let string):
            try container.encode(string)
        case .stringArray(let stringArray):
            try container.encode(stringArray)
        case .stringStringMap(let stringStringMap):
            try container.encode(stringStringMap)
        case .bool(let boolValue):
            try container.encode(boolValue)
        }
    }
    
    var value:Any {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .bool(let value):
            return value
        case .stringArray(let value):
            return value
        case .stringStringMap(let value):
            return value
        }
    }
    
    public init(value: Any) {
        if let value = value as? String {
            self = .string(value)
        } else if let value = value as? Int {
            self = .int(value)
        } else if let value = value as? Bool {
            self = .bool(value)
        } else if let value = value as? [String] {
            self = .stringArray(value)
        } else if let value = value as? [String:String] {
            self = .stringStringMap(value)
        } else {
            self = .string("Bad Data") // TODO: Fix this
        }
    }
}
