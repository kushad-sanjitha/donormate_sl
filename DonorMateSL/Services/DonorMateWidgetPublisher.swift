//
//  DonorMateWidgetPublisher.swift
//  DonorMateSL
//
//  Created by user300742 on 10/26/26.
//

import Foundation
import WidgetKit

@MainActor
enum DonorMateWidgetPublisher {
    static func synchronize(
        userID: String?,
        donorState: DonorRecordsState,
        now: Date = .now
    ) {
        guard let sharedStore = DonorMateWidgetSharedStore() else {
            return
        }

        guard let userID, !userID.isEmpty,
              donorState.isVerified,
              case .linked = donorState.linkState,
              let latestRecord = donorState.records.max(by: { $0.date < $1.date }),
              let nextPossibleDate = DonationWaitingPeriodPolicy
                .effectiveNextPossibleDonationDate(for: latestRecord),
              isReadyStateKnown(for: latestRecord, now: now) else {
            sharedStore.clear()
            WidgetCenter.shared.reloadTimelines(ofKind: "DonorMateSLStatus")
            return
        }

        let snapshot = DonorMateWidgetSnapshot(
            ownerID: userID,
            lastDonationDate: latestRecord.date,
            nextPossibleDonationDate: nextPossibleDate,
            publishedAt: now,
            isVerified: true
        )

        guard sharedStore.save(snapshot) else {
            sharedStore.clear()
            return
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "DonorMateSLStatus")
    }

    private static func isReadyStateKnown(
        for record: DonationRecord,
        now: Date
    ) -> Bool {
        switch DonationReadinessCalculator.readiness(for: record, currentDate: now) {
        case .ready, .notReady:
            return true
        case .unknown:
            return false
        }
    }
}
