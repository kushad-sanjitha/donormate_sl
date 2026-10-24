//
//  UrgentBloodNeedCatalog.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation

nonisolated enum UrgentBloodNeedCatalog {

    static let urgentNeeds: [UrgentBloodNeed] = [
        UrgentBloodNeed(
            id: "matara-a-positive-urgent",
            bloodGroup: "A+",
            locationID: "matara-blood-bank",
            status: .active,
            publishedAt: date(year: 2026, month: 10, day: 24, hour: 9),
            expiresAt: date(year: 2026, month: 10, day: 31, hour: 17),
            sourceText: "Demonstration request only. No live blood-bank appeal has been verified.",
            isDemonstration: true
        )
    ]

    static func urgentNeed(for id: String) -> UrgentBloodNeed? {
        urgentNeeds.first { $0.id == id }
    }

    private static func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int
    ) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 5 * 3_600 + 30 * 60) ?? .gmt

        guard let value = calendar.date(from: DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour
        )) else {
            preconditionFailure("Invalid demonstration date")
        }

        return value
    }
}
