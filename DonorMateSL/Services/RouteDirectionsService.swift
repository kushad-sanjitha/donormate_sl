//
//  RouteDirectionsService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import Foundation
import CoreLocation
import MapKit

enum RouteDirectionsError: LocalizedError {
    case routeNotFound

    var errorDescription: String? {
        switch self {
        case .routeNotFound:
            return "No driving route could be found."
        }
    }
}

struct RouteDirectionsService {

    func calculateRoute(
        from sourceLocation: CLLocation,
        to destination: DonationLocation
    ) async throws -> MKRoute {

        let sourceMapItem = MKMapItem(
            location: sourceLocation,
            address: nil
        )

        let destinationLocation = CLLocation(
            latitude: destination.latitude,
            longitude: destination.longitude
        )

        let destinationMapItem = MKMapItem(
            location: destinationLocation,
            address: nil
        )

        let request = MKDirections.Request()

        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = .automobile
        request.requestsAlternateRoutes = false

        let directions = MKDirections(
            request: request
        )

        let response = try await directions.calculate()

        guard let route = response.routes.first else {
            throw RouteDirectionsError.routeNotFound
        }

        return route
    }
}
