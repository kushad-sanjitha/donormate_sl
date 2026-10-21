//
//  DonorRecordsStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/21/26.
//

import Foundation
import Combine
import Testing
@testable import DonorMateSL

@MainActor
struct DonorRecordsStoreTests {

    @Test
    func storeStartsUnlinkedWithoutDonorData() {

        let store =
            DonorRecordsStore()

        #expect(
            store.linkState == .unlinked
        )

        #expect(
            store.profile == nil
        )

        #expect(
            store.records.isEmpty
        )

        #expect(
            store.latestRecord == nil
        )

        #expect(
            store.reportedDonationCount == nil
        )

        #expect(
            store.loadedDonationCount == 0
        )
    }

    @Test
    func unlinkedInitializationDiscardsSuppliedRecords() {

        let record =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Matara Blood Bank"
            )

        let store =
            DonorRecordsStore(
                linkState: .unlinked,
                records: [record]
            )

        #expect(
            store.linkState == .unlinked
        )

        #expect(
            store.profile == nil
        )

        #expect(
            store.records.isEmpty
        )

        #expect(
            store.latestRecord == nil
        )
    }

    @Test
    func linkedInitializationPreservesProfileAndRecords() throws {

        let profile =
            makeProfile()

        let record =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Matara Blood Bank"
            )

        let store =
            DonorRecordsStore(
                linkState: .linked(
                    profile: profile
                ),
                records: [record]
            )

        let linkedProfile =
            try #require(
                store.profile
            )

        #expect(
            linkedProfile == profile
        )

        #expect(
            store.records.count == 1
        )

        #expect(
            store.records.first?.location ==
                "Matara Blood Bank"
        )
    }

    @Test
    func linkedStoreWithEmptyRecordsHasNoLatestRecord() {

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
            records: []
        )

        #expect(
            store.latestRecord == nil
        )

        #expect(
            store.recordsNewestFirst.isEmpty
        )
    }

    @Test
    func singleRecordIsSelectedAsLatest() throws {

        let record =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Matara Blood Bank"
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
            records: [record]
        )

        let latest =
            try #require(
                store.latestRecord
            )

        #expect(
            latest.date == record.date
        )

        #expect(
            latest.location ==
                "Matara Blood Bank"
        )
    }

    @Test
    func latestRecordIsSelectedFromUnsortedRecords() throws {

        let oldest =
            makeRecord(
                year: 2025,
                month: 5,
                day: 6,
                location: "Oldest"
            )

        let latest =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Latest"
            )

        let middle =
            makeRecord(
                year: 2026,
                month: 1,
                day: 16,
                location: "Middle"
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
            records: [
                middle,
                oldest,
                latest
            ]
        )

        let result =
            try #require(
                store.latestRecord
            )

        #expect(
            result.location == "Latest"
        )

        #expect(
            result.date == latest.date
        )
    }

    @Test
    func recordsAreProvidedNewestFirst() {

        let oldest =
            makeRecord(
                year: 2025,
                month: 5,
                day: 6,
                location: "Oldest"
            )

        let latest =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Latest"
            )

        let middle =
            makeRecord(
                year: 2026,
                month: 1,
                day: 16,
                location: "Middle"
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
            records: [
                oldest,
                latest,
                middle
            ]
        )

        let locations =
            store.recordsNewestFirst.map(
                \.location
            )

        #expect(
            locations == [
                "Latest",
                "Middle",
                "Oldest"
            ]
        )
    }

    @Test
    func reportedDonationCountRemainsSeparateFromLoadedRecordCount() {

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            ),
            records: DonorDemoData.records
        )

        #expect(
            store.reportedDonationCount == 6
        )

        #expect(
            store.loadedDonationCount == 4
        )
    }

    @Test
    func unavailableReportedCountIsNotInvented() {

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: nil
            ),
            records: DonorDemoData.records
        )

        #expect(
            store.reportedDonationCount == nil
        )

        #expect(
            store.loadedDonationCount == 4
        )
    }

    @Test
    func newerRecordUpdatesLatestRecord() throws {

        let original =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Original"
            )

        let newer =
            makeRecord(
                year: 2026,
                month: 8,
                day: 20,
                location: "Newer"
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
            records: [original]
        )

        store.replaceRecords(
            with: [
                original,
                newer
            ]
        )

        let latest =
            try #require(
                store.latestRecord
            )

        #expect(
            latest.location == "Newer"
        )

        #expect(
            latest.date == newer.date
        )
    }

    @Test
    func replacingRecordsRemovesPreviousRecords() {

        let oldRecord =
            makeRecord(
                year: 2026,
                month: 1,
                day: 16,
                location: "Old Record"
            )

        let replacement =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Replacement"
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
            records: [oldRecord]
        )

        store.replaceRecords(
            with: [replacement]
        )

        #expect(
            store.records.count == 1
        )

        #expect(
            store.records.first?.location ==
                "Replacement"
        )

        #expect(
            !store.records.contains {
                $0.location ==
                    "Old Record"
            }
        )
    }

    @Test
    func replacingRecordsWithEmptyCollectionProducesEmptyHistory() {

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
            records: [
                makeRecord(
                    year: 2026,
                    month: 5,
                    day: 18,
                    location: "Matara"
                )
            ]
        )

        store.replaceRecords(
            with: []
        )

        #expect(
            store.records.isEmpty
        )

        #expect(
            store.latestRecord == nil
        )

        #expect(
            store.loadedDonationCount == 0
        )
    }

    @Test
    func linkedDonorWithZeroRecordsRemainsLinked() throws {

        let profile =
            makeProfile(
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
    func replacingLinkedDonorKeepsProfileAndRecordsConsistent() {

        let firstProfile =
            DonorProfile(
                displayName: "First Donor",
                bloodGroup: "O+",
                reportedDonationCount: 2
            )

        let firstRecord =
            makeRecord(
                year: 2026,
                month: 1,
                day: 10,
                location: "First Donor Location"
            )

        let secondProfile =
            DonorProfile(
                displayName: "Second Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let secondRecord =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Second Donor Location"
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: firstProfile,
            records: [firstRecord]
        )

        store.replaceLinkedData(
            profile: secondProfile,
            records: [secondRecord]
        )

        let state =
            store.state

        guard case let .linked(profile) =
                state.linkState else {
            Issue.record(
                "Expected linked donor state"
            )
            return
        }

        #expect(
            profile == secondProfile
        )

        #expect(
            state.records.count == 1
        )

        #expect(
            state.records.first?.location ==
                "Second Donor Location"
        )

        #expect(
            !state.records.contains {
                $0.location ==
                    "First Donor Location"
            }
        )
    }

    @Test
    func publishedDonorReplacementsDeliverCoherentSnapshots() {

        let firstProfile =
            DonorProfile(
                displayName: "First Donor",
                bloodGroup: "O+",
                reportedDonationCount: 2
            )

        let firstRecord =
            makeRecord(
                year: 2026,
                month: 1,
                day: 10,
                location: "First Donor Location"
            )

        let secondProfile =
            DonorProfile(
                displayName: "Second Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let secondRecord =
            makeRecord(
                year: 2026,
                month: 5,
                day: 18,
                location: "Second Donor Location"
            )

        let store =
            DonorRecordsStore()

        var receivedStates: [DonorRecordsState] = []

        let cancellable =
            store.$state
                .dropFirst()
                .sink { state in
                    receivedStates.append(
                        state
                    )
                }

        store.replaceLinkedData(
            profile: firstProfile,
            records: [firstRecord]
        )

        store.replaceLinkedData(
            profile: secondProfile,
            records: [secondRecord]
        )

        withExtendedLifetime(
            cancellable
        ) {
            #expect(
                receivedStates.count == 2
            )

            guard receivedStates.count == 2 else {
                return
            }

            let firstState =
                receivedStates[0]

            guard case let .linked(firstPublishedProfile) =
                    firstState.linkState else {
                Issue.record(
                    "Expected first published state to be linked"
                )
                return
            }

            #expect(
                firstPublishedProfile ==
                    firstProfile
            )

            #expect(
                firstState.records.count == 1
            )

            #expect(
                firstState.records.first?.location ==
                    "First Donor Location"
            )

            let secondState =
                receivedStates[1]

            guard case let .linked(secondPublishedProfile) =
                    secondState.linkState else {
                Issue.record(
                    "Expected second published state to be linked"
                )
                return
            }

            #expect(
                secondPublishedProfile ==
                    secondProfile
            )

            #expect(
                secondState.records.count == 1
            )

            #expect(
                secondState.records.first?.location ==
                    "Second Donor Location"
            )
        }
    }

    @Test
    func replacingOnlyRecordsPreservesLinkedProfileAndReportedCount() throws {

        let profile =
            DonorProfile(
                displayName: "Sample Donor",
                bloodGroup: "A+",
                reportedDonationCount: 6
            )

        let originalRecord =
            makeRecord(
                year: 2026,
                month: 1,
                day: 16,
                location: "Original Record"
            )

        let replacementRecord =
            makeRecord(
                year: 2026,
                month: 8,
                day: 20,
                location: "Replacement Record"
            )

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: profile,
            records: [originalRecord]
        )

        store.replaceRecords(
            with: [replacementRecord]
        )

        let linkedProfile =
            try #require(
                store.profile
            )

        let latest =
            try #require(
                store.latestRecord
            )

        #expect(
            linkedProfile == profile
        )

        #expect(
            store.reportedDonationCount == 6
        )

        #expect(
            store.records.count == 1
        )

        #expect(
            latest.date ==
                replacementRecord.date
        )

        #expect(
            latest.location ==
                "Replacement Record"
        )
    }

    @Test
    func unlinkingClearsProfileAndDonationRecords() {

        let store =
            DonorRecordsStore()

        store.replaceLinkedData(
            profile: makeProfile(),
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

        #expect(
            store.latestRecord == nil
        )

        #expect(
            store.reportedDonationCount == nil
        )
    }

    @Test
    func unlinkedStoreDoesNotAcceptDonationRecords() {

        let store =
            DonorRecordsStore()

        store.replaceRecords(
            with: DonorDemoData.records
        )

        #expect(
            store.linkState == .unlinked
        )

        #expect(
            store.records.isEmpty
        )
    }

    private func makeProfile(
        reportedDonationCount: Int? = 6
    ) -> DonorProfile {

        DonorProfile(
            displayName: "Sample Donor",
            bloodGroup: "A+",
            reportedDonationCount:
                reportedDonationCount
        )
    }

    private func makeRecord(
        year: Int,
        month: Int,
        day: Int,
        location: String
    ) -> DonationRecord {

        DonationRecord(
            date: makeDate(
                year: year,
                month: month,
                day: day
            ),
            location: location,
            donationType: "Whole blood",
            recordLabel: "Blood-bank record",
            recordReference: nil,
            nextPossibleDonationDate: nil
        )
    }

    private func makeDate(
        year: Int,
        month: Int,
        day: Int
    ) -> Date {

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                secondsFromGMT: 0
            )!

        return calendar.date(
            from: DateComponents(
                year: year,
                month: month,
                day: day,
                hour: 12
            )
        )!
    }
}
