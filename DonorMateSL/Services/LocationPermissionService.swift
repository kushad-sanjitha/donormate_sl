//
//  LocationPermissionService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import Foundation
import CoreLocation
import Combine

enum LocationPermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
}

final class LocationPermissionService: NSObject, ObservableObject {

    @Published private(set) var status: LocationPermissionStatus

    private let locationManager: CLLocationManager

    override init() {
        let manager = CLLocationManager()
        self.locationManager = manager

        self.status = Self.mapAuthorizationStatus(
            manager.authorizationStatus
        )

        super.init()

        self.locationManager.delegate = self
    }

    func requestWhenInUsePermission() {

        let currentStatus = locationManager.authorizationStatus

        switch currentStatus {

        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()

        case .authorizedWhenInUse,
             .authorizedAlways:
            updateStatus(from: currentStatus)

        case .denied,
             .restricted:
            updateStatus(from: currentStatus)

        @unknown default:
            updateStatus(from: currentStatus)
        }
    }

    func refreshStatus() {
        updateStatus(
            from: locationManager.authorizationStatus
        )
    }

    private static func mapAuthorizationStatus(
        _ authorizationStatus: CLAuthorizationStatus
    ) -> LocationPermissionStatus {

        switch authorizationStatus {

        case .notDetermined:
            return .notDetermined

        case .authorizedWhenInUse,
             .authorizedAlways:
            return .authorized

        case .denied:
            return .denied

        case .restricted:
            return .restricted

        @unknown default:
            return .restricted
        }
    }

    private func updateStatus(
        from authorizationStatus: CLAuthorizationStatus
    ) {

        let newStatus = Self.mapAuthorizationStatus(
            authorizationStatus
        )

        DispatchQueue.main.async {
            self.status = newStatus
        }
    }
}

extension LocationPermissionService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {
        updateStatus(
            from: manager.authorizationStatus
        )
    }
}
