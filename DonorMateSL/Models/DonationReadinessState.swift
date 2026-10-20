//
//  DonationReadinessState.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation

nonisolated enum DonationReadinessState: Equatable, Sendable {
    case ready
    case notReady(daysRemaining: Int)
    case unknown
}
