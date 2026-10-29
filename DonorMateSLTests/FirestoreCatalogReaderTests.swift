//
//  FirestoreCatalogReaderTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/29/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct FirestoreCatalogReaderTests {
    private let bankID = "matara-blood-bank"

    private var bankFields: [String: Any] {
        [
            "name": "Matara Blood Bank",
            "type": "bloodBank",
            "latitude": 5.9497,
            "longitude": 80.5428,
            "detail": "Blood donation services",
            "openingHours": "8:00 AM–4:00 PM"
        ]
    }

    private var urgentFields: [String: Any] {
        [
            "bloodGroup": "A+",
            "locationID": bankID,
            "status": "active",
            "publishedAt": Date(timeIntervalSince1970: 100),
            "expiresAt": Date(timeIntervalSince1970: 300),
            "sourceText": "Fictional test appeal",
            "isDemonstration": true
        ]
    }

    @Test func validBloodBankFieldsDecode() throws {
        let location = try #require(
            FirestoreCatalogReader.decodeLocation(fields: bankFields, id: bankID)
        )
        #expect(location.id == bankID)
        #expect(location.name == "Matara Blood Bank")
        #expect(location.type == .bloodBank)
        #expect(location.latitude == 5.9497)
        #expect(location.openingHours == "8:00 AM–4:00 PM")
    }

    @Test func campFieldsDecode() throws {
        var fields = bankFields
        fields["type"] = "camp"
        let location = try #require(
            FirestoreCatalogReader.decodeLocation(fields: fields, id: "camp-1")
        )
        #expect(location.type == .camp)
    }

    @Test func unknownLocationTypeIsRejected() {
        var fields = bankFields
        fields["type"] = "hospital"
        #expect(FirestoreCatalogReader.decodeLocation(fields: fields, id: bankID) == nil)
    }

    @Test func outOfRangeCoordinatesAreRejected() {
        var fields = bankFields
        fields["latitude"] = 91.0
        #expect(FirestoreCatalogReader.decodeLocation(fields: fields, id: bankID) == nil)
        fields["latitude"] = 5.9497
        fields["longitude"] = -181.0
        #expect(FirestoreCatalogReader.decodeLocation(fields: fields, id: bankID) == nil)
    }

    @Test func missingOrEmptyLocationFieldsAreRejected() {
        var fields = bankFields
        fields.removeValue(forKey: "detail")
        #expect(FirestoreCatalogReader.decodeLocation(fields: fields, id: bankID) == nil)
        #expect(FirestoreCatalogReader.decodeLocation(fields: bankFields, id: "") == nil)
    }

    @Test func locationStoreStartsEmptyUntilFirestoreLoads() {
        #expect(DonationLocationStore().locations.isEmpty)
    }

    @Test func decodedLocationCanReplaceStoreContents() throws {
        let decoded = try #require(
            FirestoreCatalogReader.decodeLocation(fields: bankFields, id: bankID)
        )
        let store = DonationLocationStore()
        store.replaceLocations(with: [decoded])
        #expect(store.location(for: bankID) == decoded)
    }

    @Test func validUrgentFieldsDecode() throws {
        let request = try #require(
            FirestoreCatalogReader.decodeUrgentNeed(fields: urgentFields, id: "need-1")
        )
        #expect(request.bloodGroup == "A+")
        #expect(request.locationID == bankID)
        #expect(request.status == .active)
        #expect(request.isDemonstration)
    }

    @Test func unknownUrgentStatusIsRejected() {
        var fields = urgentFields
        fields["status"] = "pending"
        #expect(FirestoreCatalogReader.decodeUrgentNeed(fields: fields, id: "need-1") == nil)
    }

    @Test func missingDatesAreRejected() {
        var fields = urgentFields
        fields.removeValue(forKey: "publishedAt")
        #expect(FirestoreCatalogReader.decodeUrgentNeed(fields: fields, id: "need-1") == nil)
    }

    @Test func invalidTimeWindowIsRejected() {
        var fields = urgentFields
        fields["expiresAt"] = Date(timeIntervalSince1970: 50)
        #expect(FirestoreCatalogReader.decodeUrgentNeed(fields: fields, id: "need-1") == nil)
    }

    @Test func urgentRequestNeedsIDAndLocation() {
        #expect(FirestoreCatalogReader.decodeUrgentNeed(fields: urgentFields, id: "") == nil)
        var fields = urgentFields
        fields["locationID"] = ""
        #expect(FirestoreCatalogReader.decodeUrgentNeed(fields: fields, id: "need-1") == nil)
    }

    @Test func missingDemonstrationFlagDefaultsToSaferValue() throws {
        var fields = urgentFields
        fields.removeValue(forKey: "isDemonstration")
        let request = try #require(
            FirestoreCatalogReader.decodeUrgentNeed(fields: fields, id: "need-1")
        )
        #expect(request.isDemonstration)
    }

    @Test func activeUrgentWindowUsesInclusiveStartAndExclusiveExpiry() throws {
        let request = try #require(
            FirestoreCatalogReader.decodeUrgentNeed(fields: urgentFields, id: "need-1")
        )
        #expect(!request.isActive(at: request.publishedAt.addingTimeInterval(-1)))
        #expect(request.isActive(at: request.publishedAt))
        #expect(request.isActive(at: request.expiresAt.addingTimeInterval(-1)))
        #expect(!request.isActive(at: request.expiresAt))
    }

    @Test func closedUrgentRequestIsNeverActive() throws {
        var fields = urgentFields
        fields["status"] = "closed"
        let request = try #require(
            FirestoreCatalogReader.decodeUrgentNeed(fields: fields, id: "need-1")
        )
        #expect(!request.isActive(at: request.publishedAt))
    }

    @Test func urgentStoreStartsEmptyUntilFirestoreLoads() {
        #expect(UrgentBloodNeedStore().needs.isEmpty)
    }

    @Test func decodedUrgentRequestIsAvailableInStore() throws {
        let decoded = try #require(
            FirestoreCatalogReader.decodeUrgentNeed(fields: urgentFields, id: "need-1")
        )
        let store = UrgentBloodNeedStore()
        store.replaceNeeds(with: [decoded])
        #expect(store.need(for: "need-1") == decoded)
    }
}
