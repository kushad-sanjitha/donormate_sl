//
//  DonorDataSourceProvenanceTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/23/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct DonorDataSourceProvenanceTests {

    @Test
    func demonstrationRecordsAreNotAutomaticallyVerified() {
        let store = DonorRecordsStore(
            linkState: .linked(profile: DonorDemoData.profile),
            records: DonorDemoData.records
        )
        #expect(store.isVerified == false)
    }

    @Test
    func authorisedReplacementRetainsVerificationWhenRecordsRefresh() {
        let store = DonorRecordsStore()
        store.replaceLinkedData(
            profile: DonorDemoData.profile,
            records: DonorDemoData.records,
            isVerified: true
        )
        store.replaceRecords(with: [])

        #expect(store.isVerified == true)
        #expect(store.records.isEmpty)
    }

    @Test
    func unlinkClearsVerificationAndDonorData() {
        let store = DonorRecordsStore()
        store.replaceLinkedData(
            profile: DonorDemoData.profile,
            records: DonorDemoData.records,
            isVerified: true
        )
        store.unlink()

        #expect(store.isVerified == false)
        #expect(store.profile == nil)
        #expect(store.records.isEmpty)
    }
}
