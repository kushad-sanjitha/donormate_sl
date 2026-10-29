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

        let latestDonationText =
            formattedDate(
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
                detail: "Based on your latest recorded whole-blood donation on \(latestDonationText), the minimum four-month waiting period has passed.",
                compactMessage: "Recorded minimum waiting period completed. Final eligibility is confirmed by authorised staff.",
                style: .success
            )

        case let .notReady(daysRemaining):

            guard let effectiveDate =
                    DonationWaitingPeriodPolicy
                        .effectiveNextPossibleDonationDate(
                            for: latestRecord,
                            calendar: calendar
                        ) else {

                return unknownPresentation(
                    latestDonationText:
                        latestDonationText
                )
            }

            let nextPossibleText =
                formattedDate(
                    effectiveDate
                )

            let dayWord =
                daysRemaining == 1
                    ? "day"
                    : "days"

            return DonationReadinessPresentation(
                badgeTitle: "Date check",
                title: "\(daysRemaining) \(dayWord) remaining",
                detail: "Based on your latest recorded whole-blood donation on \(latestDonationText), the effective next possible donation date is \(nextPossibleText).",
                compactMessage: "\(daysRemaining) \(dayWord) remain in the recorded minimum waiting period.",
                style: .warning
            )

        case .unknown:
            return unknownPresentation(
                latestDonationText:
                    latestDonationText
            )
        }
    }

    private static func unknownPresentation(
        latestDonationText: String
    ) -> DonationReadinessPresentation {

        DonationReadinessPresentation(
            badgeTitle: "Date check unavailable",
            title: "Waiting-period status unavailable",
            detail: "Your latest recorded donation is \(latestDonationText), but DonorMate cannot safely calculate a whole-blood waiting-period status from the available record.",
            compactMessage: "Waiting-period status is unavailable from the linked donor record.",
            style: .neutral
        )
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
