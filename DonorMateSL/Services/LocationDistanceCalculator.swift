//
//  LocationDistanceCalculator.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import CoreLocation

nonisolated enum LocationDistanceCalculator {

    static func formattedDistance(
        from userLocation: CLLocation,
        to destination: DonationLocation
    ) -> String {

        let destinationLocation =
            CLLocation(
                latitude: destination.latitude,
                longitude: destination.longitude
            )

        let distanceInMetres =
            userLocation.distance(
                from: destinationLocation
            )

        let distanceInKilometres =
            distanceInMetres / 1000

        return String(
            format: "%.1f km",
            distanceInKilometres
        )
    }
}
