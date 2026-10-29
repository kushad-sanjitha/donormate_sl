//
//  DonationLocationStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/23/26.
//

import Foundation
import Combine

@MainActor
final class DonationLocationStore: ObservableObject {

    @Published private(set) var locations: [DonationLocation]

    init(locations: [DonationLocation] = []) {
        self.locations = Self.uniqueValidLocations(locations)
    }

    func location(for id: String) -> DonationLocation? {
        locations.first { $0.id == id }
    }

    func replaceLocations(with locations: [DonationLocation]) {
        self.locations = Self.uniqueValidLocations(locations)
    }

    private static func uniqueValidLocations(
        _ locations: [DonationLocation]
    ) -> [DonationLocation] {
        var ids = Set<String>()

        return locations.filter { location in
            guard !location.id.isEmpty,
                  !location.name.isEmpty,
                  location.latitude.isFinite,
                  location.longitude.isFinite,
                  (-90...90).contains(location.latitude),
                  (-180...180).contains(location.longitude) else {
                return false
            }

            return ids.insert(location.id).inserted
        }
    }
}
