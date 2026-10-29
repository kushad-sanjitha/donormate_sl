//
//  DonorLinkState.swift
//  DonorMateSL
//
//  Created by user300742 on 10/21/26.
//

import Foundation

nonisolated enum DonorLinkState: Equatable, Sendable {
    case unlinked
    case linked(profile: DonorProfile)
}
