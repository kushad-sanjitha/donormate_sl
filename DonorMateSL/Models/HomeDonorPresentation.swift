//
//  HomeDonorPresentation.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation

nonisolated struct HomeDonorPresentation: Sendable {

    let isLinked: Bool

    let greeting: String
    let initials: String?

    let latestRecord: DonationRecord?
    let reportedDonationCount: Int?

    let readiness: DonationReadinessState
    let countdownProgress: Double?
}
