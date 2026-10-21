//
//  DonorLinkStateTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/21/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct DonorLinkStateTests {

    @Test
    func newStoreIsUnlinked() {

        let store =
            DonorRecordsStore()

        #expect(
            store.linkState == .unlinked
        )

        #expect(
            store.profile == nil
        )
    }

    @Test
    func linkingValidProfileProducesLinkedState() throws {

        let profile =
            makeProfile(
                name: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: profile,
            records: DonorDemoData.records
        )

        let linkedProfile =
            try #require(
                store.profile
            )

        #expect(
            linkedProfile == profile
        )

        #expect(
            store.linkState ==
                .linked(
                    profile: profile
                )
        )
    }

    @Test
    func linkedStateDoesNotDependOnHavingDonationRecords() throws {

        let profile =
            makeProfile(
                name: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 0
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: profile,
            records: []
        )

        let linkedProfile =
            try #require(
                store.profile
            )

        #expect(
            linkedProfile == profile
        )

        #expect(
            store.linkState ==
                .linked(
                    profile: profile
                )
        )

        #expect(
            store.records.isEmpty
        )
    }

    @Test
    func linkingAnotherProfileReplacesPreviousLinkedState() throws {

        let firstProfile =
            makeProfile(
                name: "First Donor",
                bloodGroup: "O+",
                reportedDonationCount: 2
            )

        let secondProfile =
            makeProfile(
                name: "Second Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: firstProfile,
            records: []
        )

        store.replaceLinkedData(
            profile: secondProfile,
            records: []
        )

        let linkedProfile =
            try #require(
                store.profile
            )

        #expect(
            linkedProfile == secondProfile
        )

        #expect(
            store.linkState ==
                .linked(
                    profile: secondProfile
                )
        )
    }

    @Test
    func unlinkingReturnsStoreToUnlinkedState() {

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(
                name: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            ),
            records: DonorDemoData.records
        )

        store.unlink()

        #expect(
            store.linkState == .unlinked
        )

        #expect(
            store.profile == nil
        )

        #expect(
            store.records.isEmpty
        )
    }

    private func makeProfile(
        name: String,
        bloodGroup: String,
        reportedDonationCount: Int?
    ) -> DonorProfile {

        DonorProfile(
            displayName: name,
            bloodGroup: bloodGroup,
            reportedDonationCount:
                reportedDonationCount
        )
    }
}
