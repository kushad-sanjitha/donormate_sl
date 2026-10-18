//
//  DonationLocationCatalog.swift
//  DonorMateSL
//
//  Created by user300742 on 10/18/26.
//

import Foundation

enum DonationLocationCatalog {

    static let locations: [DonationLocation] = [
        DonationLocation(
            id: "matara-donation-camp",
            name: "Matara Donation Camp",
            type: .camp,
            latitude: 5.9485,
            longitude: 80.5353,
            detail: "Sat · 9:00 AM"
        ),
        DonationLocation(
            id: "matara-blood-bank",
            name: "Matara Blood Bank",
            type: .bloodBank,
            latitude: 5.9497,
            longitude: 80.5428,
            detail: "Open today"
        ),
        DonationLocation(
            id: "walgama-donation-camp",
            name: "Walgama Donation Camp",
            type: .camp,
            latitude: 5.9706,
            longitude: 80.5241,
            detail: "Sun · 8:30 AM"
        )
    ]

    static func location(
        for id: String
    ) -> DonationLocation? {

        locations.first {
            $0.id == id
        }
    }
}
