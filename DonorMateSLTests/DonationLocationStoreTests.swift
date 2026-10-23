//
//  DonationLocationStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/23/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct DonationLocationStoreTests {

    @Test
    func startsWithProvidedLocationsAndLooksUpByID() {
        let first = makeLocation(id: "first")
        let store = DonationLocationStore(locations: [first])

        #expect(store.locations.map(\.id) == ["first"])
        #expect(store.location(for: "first")?.name == first.name)
        #expect(store.location(for: "missing") == nil)
    }

    @Test
    func replacesOldLocationsWithoutRetainingOldIdentifiers() {
        let store = DonationLocationStore(locations: [makeLocation(id: "old")])
        store.replaceLocations(with: [makeLocation(id: "new")])

        #expect(store.location(for: "old") == nil)
        #expect(store.location(for: "new") != nil)
        #expect(store.locations.count == 1)
    }

    @Test
    func updatingCoordinatesForSameIDUpdatesSource() {
        let store = DonationLocationStore(locations: [makeLocation(id: "bank")])
        let updated = DonationLocation(
            id: "bank", name: "Updated Bank", type: .bloodBank,
            latitude: 6.1, longitude: 79.9, detail: "New listing",
            openingHours: "9:00 AM–5:00 PM"
        )
        store.replaceLocations(with: [updated])

        #expect(store.location(for: "bank")?.latitude == 6.1)
        #expect(store.location(for: "bank")?.openingHours == "9:00 AM–5:00 PM")
    }

    @Test
    func emptyUpdatesClearLocations() {
        let store = DonationLocationStore(locations: [makeLocation(id: "old")])
        store.replaceLocations(with: [])
        #expect(store.locations.isEmpty)
    }

    @Test
    func duplicateAndInvalidLocationsAreExcluded() {
        let store = DonationLocationStore(locations: [
            makeLocation(id: "one"),
            makeLocation(id: "one"),
            DonationLocation(id: "invalid", name: "Bad", type: .camp,
                             latitude: 100, longitude: 80, detail: "Unusable")
        ])

        #expect(store.locations.count == 1)
        #expect(store.locations.first?.id == "one")
    }

    private func makeLocation(id: String) -> DonationLocation {
        DonationLocation(
            id: id, name: "Example", type: .bloodBank,
            latitude: 5.9485, longitude: 80.5353, detail: "Listing"
        )
    }
}
