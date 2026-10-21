//
//  HomeDonorPresentationBuilder.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation

nonisolated enum HomeDonorPresentationBuilder {

    static func presentation(
        linkState: DonorLinkState,
        latestRecord: DonationRecord?,
        currentDate: Date,
        calendar: Calendar = .current
    ) -> HomeDonorPresentation {

        switch linkState {

        case .unlinked:
            return HomeDonorPresentation(
                isLinked: false,
                greeting: "Welcome to DonorMate",
                initials: nil,
                latestRecord: nil,
                reportedDonationCount: nil,
                readiness: .unknown,
                countdownProgress: nil
            )

        case let .linked(profile):

            let readiness =
                DonationReadinessCalculator
                    .readiness(
                        for: latestRecord,
                        currentDate: currentDate,
                        calendar: calendar
                    )

            let progress =
                DonationCountdownProgressCalculator
                    .progress(
                        for: latestRecord,
                        currentDate: currentDate,
                        calendar: calendar
                    )

            return HomeDonorPresentation(
                isLinked: true,
                greeting:
                    greeting(
                        for: profile.displayName
                    ),
                initials:
                    initials(
                        for: profile.displayName
                    ),
                latestRecord:
                    latestRecord,
                reportedDonationCount:
                    profile.reportedDonationCount,
                readiness:
                    readiness,
                countdownProgress:
                    progress
            )
        }
    }

    private static func greeting(
        for displayName: String
    ) -> String {

        let nameParts =
            displayName
                .split {
                    $0.isWhitespace
                }

        guard let firstName =
                nameParts.first else {
            return "Welcome to DonorMate"
        }

        return "Hi, \(firstName)"
    }

    private static func initials(
        for displayName: String
    ) -> String? {

        let nameParts =
            displayName
                .split {
                    $0.isWhitespace
                }

        guard !nameParts.isEmpty else {
            return nil
        }

        return nameParts
            .prefix(2)
            .compactMap {
                $0.first
            }
            .map {
                String($0)
            }
            .joined()
            .uppercased()
    }
}
