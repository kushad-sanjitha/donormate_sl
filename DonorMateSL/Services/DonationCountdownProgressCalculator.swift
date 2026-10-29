//
//  DonationCountdownProgressCalculator.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation

nonisolated enum DonationCountdownProgressCalculator {

    static func progress(
        for latestRecord: DonationRecord?,
        currentDate: Date,
        calendar: Calendar = .current
    ) -> Double? {

        guard let latestRecord else {
            return nil
        }

        let donationDay =
            calendar.startOfDay(
                for: latestRecord.date
            )

        let currentDay =
            calendar.startOfDay(
                for: currentDate
            )

        guard donationDay <= currentDay else {
            return nil
        }

        guard let nextPossibleDay =
                DonationWaitingPeriodPolicy
                    .effectiveNextPossibleDonationDate(
                        for: latestRecord,
                        calendar: calendar
                    ) else {
            return nil
        }

        if currentDay >= nextPossibleDay {
            return 1
        }

        guard let totalDays =
                calendar.dateComponents(
                    [.day],
                    from: donationDay,
                    to: nextPossibleDay
                ).day,
              totalDays > 0 else {
            return nil
        }

        guard let elapsedDays =
                calendar.dateComponents(
                    [.day],
                    from: donationDay,
                    to: currentDay
                ).day,
              elapsedDays >= 0 else {
            return nil
        }

        let progress =
            Double(elapsedDays)
            / Double(totalDays)

        return min(
            max(progress, 0),
            1
        )
    }
}
