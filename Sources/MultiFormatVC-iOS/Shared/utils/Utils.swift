/**
 *
 * Utils.swift
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

public func futureDate(quantity: Int, type: Calendar.Component) -> Date {
    var dateComponent = DateComponents()
    dateComponent.setValue(quantity, for: type)
    return Calendar.current.date(byAdding: dateComponent, to: Date())!
}

public func futureDateByAddingDays(_ quantity: Int) -> Date {
    return futureDate(quantity: quantity, type: .day)
}

public func futureDateByAddingYears(_ quantity: Int) -> Date {
    return futureDate(quantity: quantity, type: .year)
}

public func futureDateByAddingMonths(_ quantity: Int) -> Date {
    return futureDate(quantity: quantity, type: .month)
}

public func futureDateByAddingHours(_ quantity: Int) -> Date {
    return futureDate(quantity: quantity, type: .hour)
}

public func futureDateByAddingMinutes(_ quantity: Int) -> Date {
    return futureDate(quantity: quantity, type: .minute)
}

public func base64EncodeString(_ str: String) -> String? {
    if let data = str.data(using: .utf8) {
        let base64String = data.base64URLEncodedString()
        return base64String
    }
    return nil
}
