//
//  DonorDemoData.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation

nonisolated enum DonorDemoData {

    static let profile =
        DonorProfile(
            displayName: "Sample Donor",
            bloodGroup: "A+",
            reportedDonationCount: 6
        )

    static let records: [DonationRecord] = [
        DonationRecord(
            date: makeDate(
                year: 2026,
                month: 5,
                day: 18
            ),
            location: "Matara Blood Bank",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: "DB-2026-0518-006",
            nextPossibleDonationDate: makeDate(
                year: 2026,
                month: 9,
                day: 18
            )
        ),
        DonationRecord(
            date: makeDate(
                year: 2026,
                month: 1,
                day: 16
            ),
            location: "Matara",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate: nil
        ),
        DonationRecord(
            date: makeDate(
                year: 2025,
                month: 9,
                day: 12
            ),
            location: "Matara",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate: nil
        ),
        DonationRecord(
            date: makeDate(
                year: 2025,
                month: 5,
                day: 6
            ),
            location: "Matara",
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate: nil
        )
    ]

    private static func makeDate(
        year: Int,
        month: Int,
        day: Int
    ) -> Date {

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                identifier: "Asia/Colombo"
            )!

        return calendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: 12
            )
        )!
    }
}
