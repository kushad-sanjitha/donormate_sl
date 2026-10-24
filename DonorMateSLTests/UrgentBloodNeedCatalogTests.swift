//
//  UrgentBloodNeedCatalogTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct UrgentBloodNeedCatalogTests {

    @Test
    func catalogContainsOneDemonstrationRequest() {
        #expect(UrgentBloodNeedCatalog.urgentNeeds.count == 1)
    }

    @Test
    func requestIdentifiersAreUnique() {
        let identifiers = UrgentBloodNeedCatalog.urgentNeeds.map(\.id)
        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test
    func knownRequestLookupReturnsMatchingData() throws {
        let need = try #require(
            UrgentBloodNeedCatalog.urgentNeed(for: "matara-a-positive-urgent")
        )
        #expect(need.bloodGroup == "A+")
        #expect(need.locationID == "matara-blood-bank")
        #expect(need.status == .active)
    }

    @Test
    func unknownRequestIDReturnsNil() {
        #expect(UrgentBloodNeedCatalog.urgentNeed(for: "unknown") == nil)
    }

    @Test
    func emptyRequestIDReturnsNil() {
        #expect(UrgentBloodNeedCatalog.urgentNeed(for: "") == nil)
    }

    @Test
    func everyRequestCanBeLookedUp() throws {
        for need in UrgentBloodNeedCatalog.urgentNeeds {
            let resolved = try #require(
                UrgentBloodNeedCatalog.urgentNeed(for: need.id)
            )
            #expect(resolved == need)
        }
    }

    @Test
    func requiredFieldsArePresent() {
        for need in UrgentBloodNeedCatalog.urgentNeeds {
            #expect(!need.id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!need.bloodGroup.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!need.locationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(!need.sourceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            #expect(need.publishedAt < need.expiresAt)
        }
    }

    @Test
    func everyRequestReferencesExistingLocation() {
        for need in UrgentBloodNeedCatalog.urgentNeeds {
            #expect(DonationLocationCatalog.location(for: need.locationID) != nil)
        }
    }

    @Test
    func demonstrationRequestDoesNotClaimAuthorisedPublication() throws {
        let need = try #require(UrgentBloodNeedCatalog.urgentNeeds.first)
        #expect(need.isDemonstration)
        #expect(need.sourceText.contains("Demonstration"))
    }

    @Test
    func activeWindowUsesInclusiveStartAndExclusiveExpiry() throws {
        let need = try #require(UrgentBloodNeedCatalog.urgentNeeds.first)
        #expect(!need.isActive(at: need.publishedAt.addingTimeInterval(-1)))
        #expect(need.isActive(at: need.publishedAt))
        #expect(need.isActive(at: need.expiresAt.addingTimeInterval(-1)))
        #expect(!need.isActive(at: need.expiresAt))
    }

    @Test
    func closedRequestIsNeverActive() throws {
        let need = try #require(UrgentBloodNeedCatalog.urgentNeeds.first)
        let closed = UrgentBloodNeed(
            id: need.id,
            bloodGroup: need.bloodGroup,
            locationID: need.locationID,
            status: .closed,
            publishedAt: need.publishedAt,
            expiresAt: need.expiresAt,
            sourceText: need.sourceText,
            isDemonstration: need.isDemonstration
        )
        #expect(!closed.isActive(at: need.publishedAt))
    }

    @Test
    func invalidTimeWindowCanNeverBecomeActive() throws {
        let need = try #require(UrgentBloodNeedCatalog.urgentNeeds.first)
        let invalid = UrgentBloodNeed(
            id: need.id,
            bloodGroup: need.bloodGroup,
            locationID: need.locationID,
            status: .active,
            publishedAt: need.expiresAt,
            expiresAt: need.publishedAt,
            sourceText: need.sourceText,
            isDemonstration: need.isDemonstration
        )
        #expect(!invalid.isActive(at: need.publishedAt))
    }
}
