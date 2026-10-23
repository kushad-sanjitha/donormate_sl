//
//  NationalIdentityNumberValidator.swift
//  DonorMateSL
//
//  Created by user300742 on 10/23/26.
//

import Foundation

nonisolated enum NationalIdentityNumberValidator {

    static func normalized(
        _ value: String
    ) -> String {

        value
            .uppercased()
            .filter {
                !$0.isWhitespace
                && $0 != "-"
            }
    }

    static func validated(
        _ value: String
    ) -> String? {

        let normalizedValue =
            normalized(value)

        guard isValidNormalized(
            normalizedValue
        ) else {
            return nil
        }

        return normalizedValue
    }

    static func isValid(
        _ value: String
    ) -> Bool {

        isValidNormalized(
            normalized(value)
        )
    }

    static func masked(
        _ value: String
    ) -> String {

        let normalizedValue =
            normalized(value)

        guard normalizedValue.count > 4 else {
            return normalizedValue
        }

        let visibleSuffix =
            normalizedValue.suffix(4)

        return String(
            repeating: "•",
            count:
                normalizedValue.count - 4
        ) + visibleSuffix
    }

    private static func isValidNormalized(
        _ value: String
    ) -> Bool {

        if value.count == 12,
           value.allSatisfy(\.isNumber) {

            return hasValidEncodedDay(
                value,
                yearDigitCount: 4
            )
        }

        guard value.count == 10 else {
            return false
        }

        let digits =
            String(value.prefix(9))

        guard digits.allSatisfy(\.isNumber),
              let suffix = value.last,
              suffix == "V" || suffix == "X" else {
            return false
        }

        return hasValidEncodedDay(
            value,
            yearDigitCount: 2
        )
    }

    private static func hasValidEncodedDay(
        _ value: String,
        yearDigitCount: Int
    ) -> Bool {

        let start =
            value.index(
                value.startIndex,
                offsetBy: yearDigitCount
            )

        let end =
            value.index(
                start,
                offsetBy: 3
            )

        guard let encodedDay = Int(
            value[start..<end]
        ) else {
            return false
        }

        let dayOfYear =
            encodedDay >= 500
            ? encodedDay - 500
            : encodedDay

        return (1...366).contains(
            dayOfYear
        )
    }
}
