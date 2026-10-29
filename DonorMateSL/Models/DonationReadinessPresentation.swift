//
//  DonationReadinessPresentation.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import Foundation

nonisolated struct DonationReadinessPresentation: Equatable, Sendable {

    enum Style: Equatable, Sendable {
        case success
        case warning
        case neutral
    }

    let badgeTitle: String
    let title: String
    let detail: String
    let compactMessage: String
    let style: Style
}

