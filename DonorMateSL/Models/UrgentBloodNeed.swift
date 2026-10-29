//
//  UrgentBloodNeed.swift
//  DonorMateSL
//
//  Created by user300742 on 10/20/26.
//

import Foundation

nonisolated enum UrgentBloodNeedStatus: String, Equatable, Sendable {
    case active
    case closed
}

nonisolated struct UrgentBloodNeed: Identifiable, Equatable, Sendable {

    let id: String
    let bloodGroup: String
    let locationID: String
    let status: UrgentBloodNeedStatus
    let publishedAt: Date
    let expiresAt: Date
    let sourceText: String
    let isDemonstration: Bool

    func isActive(at date: Date) -> Bool {
        status == .active &&
        publishedAt < expiresAt &&
        date >= publishedAt &&
        date < expiresAt
    }
}
