//
//  DonationReadinessPresentationBuilder.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import Foundation

nonisolated enum DonationReadinessPresentationBuilder {

    static func presentation(
        linkState: DonorLinkState,
        latestRecord: DonationRecord?,
        currentDate: Date,
        calendar: Calendar = .current
    ) -> DonationReadinessPresentation {

        guard case .linked = linkState else {
            return DonationReadinessPresentation(
                badgeTitle: "Not linked",
                title: "Readiness unavailable",
                detail: "Connect your donor record to check the recorded minimum waiting period.",
                compactMessage: "Connect your donor record to check the recorded waiting period.",
                style: .neutral
            )
        }

        guard let latestRecord else {
            return DonationReadinessPresentation(
                badgeTitle: "No donation history",
                title: "Waiting-period status unavailable",
                detail: "Your donor record is linked, but no recorded donation is available for a waiting-period check.",
                compactMessage: "No recorded donation is available for a waiting-period check.",
                style: .neutral
            )
        }

        let latestDonationText = formattedDate(
            latestRecord.date
        )

        let readiness =
            DonationReadinessCalculator.readiness(
                for: latestRecord,
                currentDate: currentDate,
                calendar: calendar
            )

        switch readiness {

        case .ready:
            return DonationReadinessPresentation(
                badgeTitle: "Date check",
                title: "Minimum wait completed",
                detail: "Based on your latest recorded donation on \(latestDonationText), the recorded minimum waiting period has passed.",
                compactMessage: "Recorded minimum waiting period completed. Final eligibility is confirmed by authorised staff.",
                style: .success
            )

        case let .notReady(daysRemaining):
            let nextPossibleText =
                latestRecord.nextPossibleDonationDate
                    .map(formattedDate)
                    ?? "the recorded next date"

            let dayWord =
                daysRemaining == 1
                    ? "day"
                    : "days"

            return DonationReadinessPresentation(
                badgeTitle: "Date check",
                title: "\(daysRemaining) \(dayWord) remaining",
                detail: "Based on your latest recorded donation on \(latestDonationText), the recorded next possible donation date is \(nextPossibleText).",
                compactMessage: "\(daysRemaining) \(dayWord) remain in the recorded minimum waiting period.",
                style: .warning
            )

        case .unknown:
            return DonationReadinessPresentation(
                badgeTitle: "Date check unavailable",
                title: "Waiting-period status unavailable",
                detail: "Your latest recorded donation is \(latestDonationText), but the linked record does not contain a valid next possible donation date for this check.",
                compactMessage: "Waiting-period status is unavailable from the linked donor record.",
                style: .neutral
            )
        }
    }

    private static func formattedDate(
        _ date: Date
    ) -> String {

        date.formatted(
            Date.FormatStyle()
                .day()
                .month(.wide)
                .year()
                .locale(
                    Locale(
                        identifier: "en_GB"
                    )
                )
        )
    }
}

