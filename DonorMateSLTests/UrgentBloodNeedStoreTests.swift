//
//  UrgentBloodNeedStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/24/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct UrgentBloodNeedStoreTests {

    private func need(
        id: String = "need-1",
        group: String = "A+",
        locationID: String = "matara-blood-bank",
        publishedAt: Date = Date(timeIntervalSince1970: 100),
        expiresAt: Date = Date(timeIntervalSince1970: 300),
        status: UrgentBloodNeedStatus = .active
    ) -> UrgentBloodNeed {
        UrgentBloodNeed(
            id: id,
            bloodGroup: group,
            locationID: locationID,
            status: status,
            publishedAt: publishedAt,
            expiresAt: expiresAt,
            sourceText: "Fictional test request",
            isDemonstration: true
        )
    }

    @Test
    func startsWithProvidedNeedsAndFindsByID() {
        let store = UrgentBloodNeedStore(needs: [need()])
        #expect(store.needs.count == 1)
        #expect(store.need(for: "need-1")?.bloodGroup == "A+")
        #expect(store.need(for: "missing") == nil)
    }

    @Test
    func ignoresInvalidAndDuplicateRequests() {
        let store = UrgentBloodNeedStore(needs: [
            need(),
            need(id: "need-1", group: "B+"),
            need(id: ""),
            need(id: "bad-group", group: "  "),
            need(id: "bad-location", locationID: ""),
            need(id: "bad-window", publishedAt: Date(timeIntervalSince1970: 300),
                 expiresAt: Date(timeIntervalSince1970: 100))
        ])
        #expect(store.needs.map(\.id) == ["need-1"])
    }

    @Test
    func activeNeedsExcludeFutureClosedAndExpiredRequests() {
        let store = UrgentBloodNeedStore(needs: [
            need(id: "active"),
            need(id: "future", publishedAt: Date(timeIntervalSince1970: 250)),
            need(id: "closed", status: .closed),
            need(id: "expired", expiresAt: Date(timeIntervalSince1970: 150))
        ])
        #expect(store.activeNeeds(at: Date(timeIntervalSince1970: 200)).map(\.id) == ["active"])
    }

    @Test
    func activeNeedsAreOrderedBySoonestExpiryThenID() {
        let store = UrgentBloodNeedStore(needs: [
            need(id: "later", expiresAt: Date(timeIntervalSince1970: 600)),
            need(id: "b", expiresAt: Date(timeIntervalSince1970: 250)),
            need(id: "a", expiresAt: Date(timeIntervalSince1970: 250))
        ])
        #expect(store.activeNeeds(at: Date(timeIntervalSince1970: 200)).map(\.id) == ["a", "b", "later"])
    }

    @Test
    func replacingNeedsRemovesOldRequests() {
        let store = UrgentBloodNeedStore(needs: [need(id: "old")])
        store.replaceNeeds(with: [need(id: "new")])
        #expect(store.need(for: "old") == nil)
        #expect(store.need(for: "new") != nil)
    }

    @Test
    func replacingWithEmptyListClearsRequests() {
        let store = UrgentBloodNeedStore(needs: [need()])
        store.replaceNeeds(with: [])
        #expect(store.needs.isEmpty)
        #expect(store.activeNeeds(at: Date(timeIntervalSince1970: 200)).isEmpty)
    }
}
