//
//  LocationDistanceCalculator.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import CoreLocation

nonisolated enum LocationDistanceCalculator {

    static func distanceInMetres(
        from userLocation: CLLocation,
        to destination: DonationLocation
    ) -> CLLocationDistance {
        let target = CLLocation(
            latitude: destination.latitude,
            longitude: destination.longitude
        )
        return userLocation.distance(from: target)
    }

    static func formattedDistance(
        from userLocation: CLLocation,
        to destination: DonationLocation
    ) -> String {
        String(
            format: "%.1f km",
            distanceInMetres(
                from: userLocation,
                to: destination
            ) / 1000
        )
    }
}
