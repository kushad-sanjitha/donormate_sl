//
//  UrgentBloodNeed.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation

struct UrgentBloodNeed: Identifiable, Sendable {

    let id: String
    let bloodGroup: String
    let locationID: String
    let alertStatus: String
    let sourceText: String
}
