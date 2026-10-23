//
//  DonorRecordProvider.swift
//  DonorMateSL
//
//  Created by user300742 on 10/23/26.
//

import Foundation

nonisolated struct DonorRecordLookupResult: Sendable {
    let profile: DonorProfile
    let records: [DonationRecord]
    let isVerified: Bool
}

@MainActor
protocol DonorRecordProvider {
    func findRecord(
        account: AccountProfile,
        donorRecordID: String
    ) async throws -> DonorRecordLookupResult?
}

struct DemoDonorRecordProvider: DonorRecordProvider {

    func findRecord(
        account: AccountProfile,
        donorRecordID: String
    ) async throws -> DonorRecordLookupResult? {
        guard let expectedID = DonorDemoData.profile.donorRecordID,
              donorRecordID.trimmingCharacters(in: .whitespacesAndNewlines)
                .uppercased() == expectedID.uppercased() else {
            return nil
        }

        return DonorRecordLookupResult(
            profile: DonorDemoData.profile,
            records: DonorDemoData.records,
            isVerified: false
        )
    }
}

