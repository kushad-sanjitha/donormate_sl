//
//  DonationReadinessCalculator.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation

nonisolated enum DonationReadinessCalculator {

    static func readiness(
        for latestRecord: DonationRecord?,
        currentDate: Date,
        calendar: Calendar = .current
    ) -> DonationReadinessState {

        guard let latestRecord else {
            return .unknown
        }

        guard let nextPossibleDonationDate =
                latestRecord.nextPossibleDonationDate else {
            return .unknown
        }

        let donationDay =
            calendar.startOfDay(
                for: latestRecord.date
            )

        let currentDay =
            calendar.startOfDay(
                for: currentDate
            )

        let nextPossibleDay =
            calendar.startOfDay(
                for: nextPossibleDonationDate
            )

        guard donationDay <= currentDay else {
            return .unknown
        }

        guard nextPossibleDay >= donationDay else {
            return .unknown
        }

        if currentDay >= nextPossibleDay {
            return .ready
        }

        guard let daysRemaining =
                calendar.dateComponents(
                    [.day],
                    from: currentDay,
                    to: nextPossibleDay
                ).day,
              daysRemaining > 0 else {
            return .unknown
        }

        return .notReady(
            daysRemaining: daysRemaining
        )
    }
}
