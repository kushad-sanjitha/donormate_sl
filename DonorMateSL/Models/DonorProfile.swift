//
//  DonorProfile.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation

nonisolated struct DonorProfile:
    Equatable,
    Sendable {

    let donorRecordID: String?
    let displayName: String
    let bloodGroup: String
    let reportedDonationCount: Int?

    init(
        donorRecordID: String? = nil,
        displayName: String,
        bloodGroup: String,
        reportedDonationCount: Int?
    ) {
        self.donorRecordID = donorRecordID
        self.displayName = displayName
        self.bloodGroup = bloodGroup
        self.reportedDonationCount =
            reportedDonationCount
    }
}
