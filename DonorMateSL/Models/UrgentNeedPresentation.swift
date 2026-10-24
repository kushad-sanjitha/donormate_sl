//
//  UrgentNeedPresentation.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import Foundation

nonisolated enum UrgentNeedDisplayState: Equatable, Sendable {
    case inactive
    case unlinked
    case bloodGroupUnavailable
    case notMatching
    case ready
    case waiting(daysRemaining: Int)
    case readinessUnknown
}

nonisolated struct UrgentNeedPresentation: Equatable, Sendable {
    let state: UrgentNeedDisplayState
    let requestTitle: String
    let matchText: String
    let statusTitle: String
    let statusDetail: String

    var canOfferDonationActions: Bool {
        state == .ready
    }

    var isActive: Bool {
        state != .inactive
    }
}
