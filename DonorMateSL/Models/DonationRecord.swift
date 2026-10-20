//
//  DonationRecord.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import Foundation

nonisolated struct DonationRecord: Sendable {

    let date: Date
    let location: String
    let donationType: String
    let recordLabel: String

    let recordReference: String?
    let nextPossibleDonationDate: Date?

    var locationAndType: String {
        "\(location) · \(donationType)"
    }
}
