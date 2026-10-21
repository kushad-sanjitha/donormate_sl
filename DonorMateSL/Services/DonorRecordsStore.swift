//
//  DonorRecordsStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation
import Combine

nonisolated struct DonorRecordsState: Sendable {

    let linkState: DonorLinkState
    let records: [DonationRecord]
}

@MainActor
final class DonorRecordsStore: ObservableObject {

    @Published private(set) var state: DonorRecordsState

    init(
        linkState: DonorLinkState = .unlinked,
        records: [DonationRecord] = []
    ) {
        switch linkState {
        case .unlinked:
            state = DonorRecordsState(
                linkState: .unlinked,
                records: []
            )

        case .linked:
            state = DonorRecordsState(
                linkState: linkState,
                records: records
            )
        }
    }

    var linkState: DonorLinkState {
        state.linkState
    }

    var records: [DonationRecord] {
        state.records
    }

    var profile: DonorProfile? {
        guard case let .linked(profile) =
                state.linkState else {
            return nil
        }

        return profile
    }

    var latestRecord: DonationRecord? {
        state.records.max {
            $0.date < $1.date
        }
    }

    var recordsNewestFirst: [DonationRecord] {
        state.records.sorted {
            $0.date > $1.date
        }
    }

    var reportedDonationCount: Int? {
        profile?.reportedDonationCount
    }

    var loadedDonationCount: Int {
        state.records.count
    }

    func replaceLinkedData(
        profile: DonorProfile,
        records: [DonationRecord]
    ) {
        state = DonorRecordsState(
            linkState: .linked(
                profile: profile
            ),
            records: records
        )
    }

    func replaceRecords(
        with records: [DonationRecord]
    ) {
        guard case .linked =
                state.linkState else {
            return
        }

        state = DonorRecordsState(
            linkState: state.linkState,
            records: records
        )
    }

    func unlink() {
        state = DonorRecordsState(
            linkState: .unlinked,
            records: []
        )
    }
}
