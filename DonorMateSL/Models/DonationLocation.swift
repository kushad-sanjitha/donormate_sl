//
//  DonationLocation.swift
//  DonorMateSL
//
//  Created by user300742 on 10/14/26.
//

import Foundation

struct DonationLocation: Identifiable {

    enum LocationType: Equatable {
        case camp
        case bloodBank
    }

    let id: String
    let name: String
    let type: LocationType
    let latitude: Double
    let longitude: Double
    let detail: String
}
