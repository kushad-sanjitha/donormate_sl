//
//  DonationRecord.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import Foundation

struct DonationRecord {

    let date: String
    let location: String
    let donationType: String
    let recordLabel: String

    let recordReference: String?
    let nextPossibleDonationDate: String?

    var locationAndType: String {
        "\(location) · \(donationType)"
    }
}
