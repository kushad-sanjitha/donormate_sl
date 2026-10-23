//
//  DonationWaitingPeriodPolicy.swift
//  DonorMateSL
//
//  Created by user300742 on 10/23/26.
//

import Foundation

nonisolated enum DonationWaitingPeriodPolicy {

    static let minimumWholeBloodIntervalMonths = 4

    static func effectiveNextPossibleDonationDate(
        for record: DonationRecord,
        calendar: Calendar = .current
    ) -> Date? {

        guard isSupportedWholeBloodRecord(
            record
        ) else {
            return nil
        }

        let donationDay =
            calendar.startOfDay(
                for: record.date
            )

        guard let minimumDate =
                calendar.date(
                    byAdding: .month,
                    value:
                        minimumWholeBloodIntervalMonths,
                    to: donationDay
                ) else {
            return nil
        }

        let minimumDay =
            calendar.startOfDay(
                for: minimumDate
            )

        guard let recordedDate =
                record.nextPossibleDonationDate else {
            return minimumDay
        }

        let recordedDay =
            calendar.startOfDay(
                for: recordedDate
            )

        guard recordedDay > donationDay else {
            return minimumDay
        }

        return max(
            minimumDay,
            recordedDay
        )
    }

    private static func isSupportedWholeBloodRecord(
        _ record: DonationRecord
    ) -> Bool {

        record.donationType
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .caseInsensitiveCompare(
                "Whole blood"
            ) == .orderedSame
    }
}
