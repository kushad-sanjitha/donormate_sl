//
//  DonorRecordProviderTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/23/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct DonorRecordProviderTests {

    @Test
    func knownDemoReferenceLoadsSharedRecordsWithoutClaimingVerification() async throws {
        let provider = DemoDonorRecordProvider()
        let result = try #require(
            try await provider.findRecord(
                account: sampleAccount,
                donorRecordID: " dm-248013 "
            )
        )

        #expect(result.profile.donorRecordID == DonorDemoData.profile.donorRecordID)
        #expect(result.records.count == DonorDemoData.records.count)
        #expect(result.isVerified == false)
    }

    @Test
    func unknownReferenceDoesNotLinkUnrelatedRecord() async throws {
        let provider = DemoDonorRecordProvider()
        let result = try await provider.findRecord(
            account: sampleAccount,
            donorRecordID: "DM-000000"
        )

        #expect(result?.profile == nil)
    }

    private var sampleAccount: AccountProfile {
        AccountProfile(
            uid: "test-user", displayName: "Test Donor",
            email: "test@example.com", nationalIdentityNumber: "970941372V"
        )
    }
}

