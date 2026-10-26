//
//  DonorMateWidgetSnapshot.swift
//  DonorMateSL
//
//  Created by user300742 on 10/26/26.
//

import Foundation

nonisolated struct DonorMateWidgetSnapshot: Codable, Equatable, Sendable {
    let ownerID: String
    let lastDonationDate: Date
    let nextPossibleDonationDate: Date
    let publishedAt: Date
    let isVerified: Bool
}

nonisolated enum DonorMateWidgetReadiness: Equatable, Sendable {
    case countdown(daysRemaining: Int, nextPossibleDate: Date)
    case ready
    case unavailable
}

nonisolated enum DonorMateWidgetReadinessResolver {
    static let maximumSnapshotAge: TimeInterval = 7 * 24 * 60 * 60

    static func resolve(
        _ snapshot: DonorMateWidgetSnapshot?,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> DonorMateWidgetReadiness {
        guard let snapshot,
              !snapshot.ownerID.isEmpty,
              snapshot.isVerified,
              snapshot.publishedAt <= now,
              now.timeIntervalSince(snapshot.publishedAt) <= maximumSnapshotAge else {
            return .unavailable
        }

        let donationDay = calendar.startOfDay(for: snapshot.lastDonationDate)
        let eligibleDay = calendar.startOfDay(for: snapshot.nextPossibleDonationDate)
        let currentDay = calendar.startOfDay(for: now)

        guard donationDay <= currentDay,
              eligibleDay >= donationDay else {
            return .unavailable
        }

        guard currentDay < eligibleDay else {
            return .ready
        }

        guard let days = calendar.dateComponents([.day], from: currentDay, to: eligibleDay).day,
              days > 0 else {
            return .unavailable
        }

        return .countdown(daysRemaining: days, nextPossibleDate: eligibleDay)
    }
}
