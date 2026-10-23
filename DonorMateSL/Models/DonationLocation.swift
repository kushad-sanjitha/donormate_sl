//
//  DonationLocation.swift
//  DonorMateSL
//
//  Created by user300742 on 10/14/26.
//

import Foundation

nonisolated struct DonationLocation: Identifiable, Sendable, Equatable {

    enum LocationType: Equatable, Sendable {
        case camp
        case bloodBank
    }

    let id: String
    let name: String
    let type: LocationType
    let latitude: Double
    let longitude: Double
    let detail: String
    let venue: String?
    let organiser: String?
    let openingHours: String?
    let contact: String?

    init(
        id: String,
        name: String,
        type: LocationType,
        latitude: Double,
        longitude: Double,
        detail: String,
        venue: String? = nil,
        organiser: String? = nil,
        openingHours: String? = nil,
        contact: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.detail = detail
        self.venue = venue
        self.organiser = organiser
        self.openingHours = openingHours
        self.contact = contact
    }
}
