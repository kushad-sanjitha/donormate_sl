//
//  DonorTestFixtures.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/29/26.
//

import Foundation
@testable import DonorMateSL

nonisolated enum DonorTestFixtures {
    static let profile = DonorProfile(
        donorRecordID: "DM-248013",
        displayName: "Sample Donor",
        bloodGroup: "A+",
        reportedDonationCount: 6
    )

    static let records: [DonationRecord] = [
        DonationRecord(
            date: makeDate(2026, 5, 18),
            location: "Matara Blood Bank",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: "DB-2026-0518-006",
            nextPossibleDonationDate: makeDate(2026, 9, 18)
        ),
        DonationRecord(
            date: makeDate(2026, 1, 16),
            location: "Matara",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate: nil
        ),
        DonationRecord(
            date: makeDate(2025, 9, 12),
            location: "Matara",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate: nil
        ),
        DonationRecord(
            date: makeDate(2025, 5, 6),
            location: "Matara",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate: nil
        )
    ]

    static let urgentNeed = UrgentBloodNeed(
        id: "matara-a-positive-urgent",
        bloodGroup: "A+",
        locationID: "matara-blood-bank",
        status: .active,
        publishedAt: makeDate(2026, 10, 24),
        expiresAt: makeDate(2026, 10, 31),
        sourceText: "Fictional test request",
        isDemonstration: true
    )

    static let nic = "200012345678"
    static let address = "24 LAKE ROAD, MATARA"

    private static func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Colombo")!
        return calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
    }
}
