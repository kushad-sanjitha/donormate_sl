//
//  LocationDistanceCalculatorTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import CoreLocation
import Testing
@testable import DonorMateSL

struct LocationDistanceCalculatorTests {

    @Test
    func sameCoordinatesReturnZeroKilometres() {

        let userLocation =
            CLLocation(
                latitude: 5.9497,
                longitude: 80.5428
            )

        let destination =
            makeLocation(
                latitude: 5.9497,
                longitude: 80.5428
            )

        let result =
            LocationDistanceCalculator.formattedDistance(
                from: userLocation,
                to: destination
            )

        #expect(
            result == "0.0 km"
        )
    }

    @Test
    func knownCoordinatesReturnExpectedFormattedDistance() {

        let userLocation =
            CLLocation(
                latitude: 0,
                longitude: 0
            )

        let destination =
            makeLocation(
                latitude: 0,
                longitude: 0.01
            )

        let result =
            LocationDistanceCalculator.formattedDistance(
                from: userLocation,
                to: destination
            )

        #expect(
            result == "1.1 km"
        )
    }

    @Test
    func nearbyCoordinatesReturnSmallNonnegativeDistance() {

        let userLocation =
            CLLocation(
                latitude: 0,
                longitude: 0
            )

        let destination =
            makeLocation(
                latitude: 0,
                longitude: 0.0001
            )

        let result =
            LocationDistanceCalculator.formattedDistance(
                from: userLocation,
                to: destination
            )

        #expect(
            result == "0.0 km"
        )
    }

    @Test
    func shortNonzeroDistanceDisplaysOneDecimalKilometres() {

        let userLocation =
            CLLocation(
                latitude: 0,
                longitude: 0
            )

        let destination =
            makeLocation(
                latitude: 0,
                longitude: 0.001
            )

        let result =
            LocationDistanceCalculator.formattedDistance(
                from: userLocation,
                to: destination
            )

        #expect(
            result == "0.1 km"
        )
    }

    @Test
    func reversingCoordinatesReturnsSameFormattedDistance() {

        let firstLatitude = 5.9497
        let firstLongitude = 80.5428

        let secondLatitude = 5.9485
        let secondLongitude = 80.5353

        let forward =
            LocationDistanceCalculator.formattedDistance(
                from: CLLocation(
                    latitude: firstLatitude,
                    longitude: firstLongitude
                ),
                to: makeLocation(
                    latitude: secondLatitude,
                    longitude: secondLongitude
                )
            )

        let reverse =
            LocationDistanceCalculator.formattedDistance(
                from: CLLocation(
                    latitude: secondLatitude,
                    longitude: secondLongitude
                ),
                to: makeLocation(
                    latitude: firstLatitude,
                    longitude: firstLongitude
                )
            )

        #expect(
            forward == reverse
        )
    }

    @Test
    func distanceIsRoundedToOneDecimalPlace() {

        let userLocation =
            CLLocation(
                latitude: 0,
                longitude: 0
            )

        let destination =
            makeLocation(
                latitude: 0,
                longitude: 0.0014
            )

        let result =
            LocationDistanceCalculator.formattedDistance(
                from: userLocation,
                to: destination
            )

        #expect(
            result == "0.2 km"
        )
    }

    private func makeLocation(
        latitude: Double,
        longitude: Double
    ) -> DonationLocation {

        DonationLocation(
            id: "test-location",
            name: "Test Location",
            type: .bloodBank,
            latitude: latitude,
            longitude: longitude,
            detail: "Test"
        )
    }
}
