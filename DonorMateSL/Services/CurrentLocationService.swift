//
//  CurrentLocationService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/14/26.
//

import Foundation
import CoreLocation
import Combine

final class CurrentLocationService: NSObject, ObservableObject {

    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var errorMessage: String?

    private let locationManager: CLLocationManager

    override init() {
        let manager = CLLocationManager()
        self.locationManager = manager

        super.init()

        self.locationManager.delegate = self
    }

    func clearCurrentLocation() {
        currentLocation = nil
        errorMessage = nil
    }

    func requestCurrentLocation() {
        errorMessage = nil
        locationManager.requestLocation()
    }
}

extension CurrentLocationService: CLLocationManagerDelegate {

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let latestLocation = locations.last else {
            return
        }

        DispatchQueue.main.async {
            self.currentLocation = latestLocation
            self.errorMessage = nil
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}
