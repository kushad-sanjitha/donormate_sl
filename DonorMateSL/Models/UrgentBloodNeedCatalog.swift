//
//  UrgentBloodNeedCatalog.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation

nonisolated enum UrgentBloodNeedCatalog {

    static let urgentNeeds: [UrgentBloodNeed] = [
        UrgentBloodNeed(
            id: "matara-a-positive-urgent",
            bloodGroup: "A+",
            locationID: "matara-blood-bank",
            alertStatus: "Active today",
            sourceText: "Prototype data unless an authorised official source is connected."
        )
    ]

    static func urgentNeed(
        for id: String
    ) -> UrgentBloodNeed? {

        urgentNeeds.first {
            $0.id == id
        }
    }
}
