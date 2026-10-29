//
//  UrgentNeedPresentationBuilder.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import Foundation

nonisolated enum UrgentNeedPresentationBuilder {

    static func presentation(
        for need: UrgentBloodNeed,
        linkState: DonorLinkState,
        readiness: DonationReadinessState,
        currentDate: Date
    ) -> UrgentNeedPresentation {
        let requestedGroup = need.bloodGroup.trimmingCharacters(in: .whitespacesAndNewlines)
        let requestTitle = need.isDemonstration
            ? "\(requestedGroup) blood request"
            : "\(requestedGroup) blood needed nearby"

        guard need.isActive(at: currentDate) else {
            return UrgentNeedPresentation(
                state: .inactive,
                requestTitle: "Blood request unavailable",
                matchText: "Request unavailable",
                statusTitle: "This request is not active",
                statusDetail: "It may be scheduled for later, closed or expired. Check with the blood bank for current information."
            )
        }

        guard case let .linked(profile) = linkState else {
            return UrgentNeedPresentation(
                state: .unlinked,
                requestTitle: requestTitle,
                matchText: "\(requestedGroup) requested",
                statusTitle: "Donor record not linked",
                statusDetail: "Connect your donor record before checking whether this request matches your blood group or waiting period."
            )
        }

        let donorGroup = profile.bloodGroup.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !donorGroup.isEmpty else {
            return UrgentNeedPresentation(
                state: .bloodGroupUnavailable,
                requestTitle: requestTitle,
                matchText: "\(requestedGroup) requested",
                statusTitle: "Your blood group is unavailable",
                statusDetail: "DonorMate cannot determine whether this request matches your record. Ask authorised blood-bank staff for guidance."
            )
        }

        guard donorGroup.caseInsensitiveCompare(requestedGroup) == .orderedSame else {
            return UrgentNeedPresentation(
                state: .notMatching,
                requestTitle: requestTitle,
                matchText: "\(requestedGroup) requested",
                statusTitle: "This request does not match your linked blood group",
                statusDetail: "Your linked record shows \(donorGroup). DonorMate does not determine clinical blood compatibility."
            )
        }

        switch readiness {
        case .ready:
            return UrgentNeedPresentation(
                state: .ready,
                requestTitle: requestTitle,
                matchText: "\(requestedGroup) match",
                statusTitle: "Your recorded waiting period is complete",
                statusDetail: "The minimum recorded interval has passed. Final donation eligibility must be confirmed by authorised blood-bank staff."
            )

        case let .notReady(daysRemaining):
            guard daysRemaining > 0 else {
                return UrgentNeedPresentation(
                    state: .readinessUnknown,
                    requestTitle: requestTitle,
                    matchText: "\(requestedGroup) match",
                    statusTitle: "Waiting-period status unavailable",
                    statusDetail: "DonorMate cannot confirm your recorded waiting interval. Please consult authorised blood-bank staff."
                )
            }

            return UrgentNeedPresentation(
                state: .waiting(daysRemaining: daysRemaining),
                requestTitle: requestTitle,
                matchText: "\(requestedGroup) match",
                statusTitle: "Your waiting period is not complete",
                statusDetail: "\(daysRemaining) day\(daysRemaining == 1 ? "" : "s") remaining based on your latest recorded donation. Do not treat a blood-group match as approval to donate."
            )

        case .unknown:
            return UrgentNeedPresentation(
                state: .readinessUnknown,
                requestTitle: requestTitle,
                matchText: "\(requestedGroup) match",
                statusTitle: "Waiting-period status unavailable",
                statusDetail: "DonorMate cannot confirm your recorded waiting interval. Please consult authorised blood-bank staff."
            )
        }
    }
}
