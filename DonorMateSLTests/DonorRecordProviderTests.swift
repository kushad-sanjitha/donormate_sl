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
    private let uid = "owner-uid"
    private let nic = "200012345678"

    @Test
    func matchingOwnerAndNICCanLink() {
        #expect(DonorRecordAccessPolicy.canLink(
            accountUID: uid, accountNIC: nic, ownerUID: uid, recordNIC: nic
        ))
    }

    @Test
    func knowledgeOfRecordIDAndNICIsNotEnoughForAnotherAccount() {
        #expect(!DonorRecordAccessPolicy.canLink(
            accountUID: "other-uid", accountNIC: nic, ownerUID: uid, recordNIC: nic
        ))
    }

    @Test
    func invalidOrDifferentNICCannotLinkEvenWhenUIDMatches() {
        #expect(!DonorRecordAccessPolicy.canLink(
            accountUID: uid, accountNIC: "000000000000", ownerUID: uid, recordNIC: nic
        ))
        #expect(!DonorRecordAccessPolicy.canLink(
            accountUID: uid, accountNIC: "200112345678", ownerUID: uid, recordNIC: nic
        ))
        #expect(!DonorRecordAccessPolicy.canLink(
            accountUID: uid, accountNIC: nil, ownerUID: uid, recordNIC: nic
        ))
    }

    @Test
    func unassignedOwnerCannotLink() {
        #expect(!DonorRecordAccessPolicy.canLink(
            accountUID: uid, accountNIC: nic, ownerUID: nil, recordNIC: nic
        ))
    }

    @Test
    func serverFieldsDecodeOwnerAndVerificationWithoutDonationHistory() throws {
        let payload = try FirestoreDonorRecordDecoder.decode(fields: [
            "nationalIdentityNumber": nic,
            "displayName": "Example Donor",
            "address": "24 LAKE ROAD, MATARA",
            "bloodGroup": "A+",
            "ownerUID": uid,
            "recordVerified": false,
            "reportedDonationCount": 0,
            "donations": [] as [[String: Any]]
        ], recordID: "DM-248013")

        #expect(payload.ownerUID == uid)
        #expect(payload.record.profile.donorRecordID == "DM-248013")
        #expect(payload.record.nicNumber == nic)
        #expect(payload.record.donationRecords.isEmpty)
        #expect(!payload.recordVerified)
    }

    @Test
    func donationEntriesDecodeFromFirestoreFields() throws {
        let donationDate = Date(timeIntervalSince1970: 1_800_000_000)
        let nextDate = Date(timeIntervalSince1970: 1_810_000_000)
        let payload = try FirestoreDonorRecordDecoder.decode(fields: [
            "nationalIdentityNumber": nic,
            "displayName": "Example Donor",
            "address": "24 LAKE ROAD, MATARA",
            "bloodGroup": "A+",
            "ownerUID": uid,
            "reportedDonationCount": 1,
            "donations": [[
                "date": donationDate,
                "location": "Matara Blood Bank",
                "donationType": "Whole blood",
                "recordLabel": "Blood-bank record",
                "recordReference": "R-001",
                "nextPossibleDonationDate": nextDate
            ]]
        ], recordID: "DM-248013")

        let record = try #require(payload.record.donationRecords.first)
        #expect(record.date == donationDate)
        #expect(record.recordReference == "R-001")
        #expect(record.nextPossibleDonationDate == nextDate)
    }

    @Test
    func malformedDonationArrayDoesNotSilentlyBecomeEmptyHistory() {
        #expect(throws: FirestoreDonorDataError.self) {
            try FirestoreDonorRecordDecoder.decode(fields: [
                "nationalIdentityNumber": nic,
                "displayName": "Example Donor",
                "address": "24 LAKE ROAD, MATARA",
                "bloodGroup": "A+",
                "donations": "wrong-type"
            ], recordID: "DM-248013")
        }
    }

    @Test
    func malformedFieldsAreRejected() {
        #expect(throws: FirestoreDonorDataError.self) {
            try FirestoreDonorRecordDecoder.decode(fields: [
                "nationalIdentityNumber": nic,
                "displayName": "Example Donor"
            ], recordID: "DM-248013")
        }
    }
}
