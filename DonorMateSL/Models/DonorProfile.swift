//
//  DonorProfile.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation

nonisolated struct DonorProfile: Equatable, Sendable {

    let displayName: String
    let bloodGroup: String
    let reportedDonationCount: Int?
}
