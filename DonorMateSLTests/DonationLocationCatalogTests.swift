//
//  DonationLocationCatalogTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct DonationLocationCatalogTests {

    @Test
    func catalogContainsThreeLocations() {

        #expect(
            DonationLocationCatalog.locations.count == 3
        )
    }

    @Test
    func locationIdentifiersAreUnique() {

        let identifiers =
            DonationLocationCatalog.locations.map(
                \.id
            )

        #expect(
            Set(identifiers).count ==
                identifiers.count
        )
    }

    @Test
    func mataraCampLookupReturnsCorrectLocation() throws {

        let location =
            try #require(
                DonationLocationCatalog.location(
                    for: "matara-donation-camp"
                )
            )

        #expect(
            location.id ==
                "matara-donation-camp"
        )

        #expect(
            location.name ==
                "Matara Donation Camp"
        )

        #expect(
            location.type ==
                .camp
        )

        #expect(
            location.latitude ==
                5.9485
        )

        #expect(
            location.longitude ==
                80.5353
        )

        #expect(
            location.detail ==
                "Sat · 9:00 AM"
        )
    }

    @Test
    func mataraBloodBankLookupReturnsCorrectLocation() throws {

        let location =
            try #require(
                DonationLocationCatalog.location(
                    for: "matara-blood-bank"
                )
            )

        #expect(
            location.id ==
                "matara-blood-bank"
        )

        #expect(
            location.name ==
                "Matara Blood Bank"
        )

        #expect(
            location.type ==
                .bloodBank
        )

        #expect(
            location.latitude ==
                5.9497
        )

        #expect(
            location.longitude ==
                80.5428
        )

        #expect(
            location.detail ==
                "Open today"
        )
    }

    @Test
    func walgamaCampLookupReturnsCorrectLocation() throws {

        let location =
            try #require(
                DonationLocationCatalog.location(
                    for: "walgama-donation-camp"
                )
            )

        #expect(
            location.id ==
                "walgama-donation-camp"
        )

        #expect(
            location.name ==
                "Walgama Donation Camp"
        )

        #expect(
            location.type ==
                .camp
        )

        #expect(
            location.latitude ==
                5.9706
        )

        #expect(
            location.longitude ==
                80.5241
        )

        #expect(
            location.detail ==
                "Sun · 8:30 AM"
        )
    }

    @Test
    func unknownLocationIdentifierReturnsNil() {

        let location =
            DonationLocationCatalog.location(
                for: "unknown-location"
            )

        #expect(
            location == nil
        )
    }

    @Test
    func emptyLocationIdentifierReturnsNil() {

        let location =
            DonationLocationCatalog.location(
                for: ""
            )

        #expect(
            location == nil
        )
    }

    @Test
    func catalogContainsCorrectLocationTypes() {

        let camps =
            DonationLocationCatalog.locations.filter {
                $0.type == .camp
            }

        let bloodBanks =
            DonationLocationCatalog.locations.filter {
                $0.type == .bloodBank
            }

        #expect(
            camps.count == 2
        )

        #expect(
            bloodBanks.count == 1
        )
    }

    @Test
    func allCoordinatesAreValid() {

        for location in
            DonationLocationCatalog.locations {

            #expect(
                location.latitude.isFinite
            )

            #expect(
                location.longitude.isFinite
            )

            #expect(
                (-90.0...90.0).contains(
                    location.latitude
                )
            )

            #expect(
                (-180.0...180.0).contains(
                    location.longitude
                )
            )
        }
    }

    @Test
    func allLocationsHaveRequiredInformation() {

        for location in
            DonationLocationCatalog.locations {

            #expect(
                !location.id
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !location.name
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !location.detail
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )
        }
    }

    @Test
    func everyCatalogLocationCanBeLookedUp() throws {

        for expectedLocation in
            DonationLocationCatalog.locations {

            let resolvedLocation =
                try #require(
                    DonationLocationCatalog.location(
                        for: expectedLocation.id
                    )
                )

            #expect(
                resolvedLocation.id ==
                    expectedLocation.id
            )

            #expect(
                resolvedLocation.name ==
                    expectedLocation.name
            )

            #expect(
                resolvedLocation.type ==
                    expectedLocation.type
            )

            #expect(
                resolvedLocation.latitude ==
                    expectedLocation.latitude
            )

            #expect(
                resolvedLocation.longitude ==
                    expectedLocation.longitude
            )

            #expect(
                resolvedLocation.detail ==
                    expectedLocation.detail
            )
        }
    }
}
