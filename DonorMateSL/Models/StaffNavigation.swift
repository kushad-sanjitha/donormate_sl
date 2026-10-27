//
//  StaffNavigation.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import Foundation

nonisolated enum StaffSection: String, CaseIterable, Sendable {
    case dashboard
    case verifyDonor

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .verifyDonor: return "Verify Donor"
        }
    }
}

nonisolated struct StaffNavigation: Equatable, Sendable {
    private(set) var section: StaffSection = .dashboard

    mutating func showDashboard() {
        section = .dashboard
    }

    mutating func showVerificationInstructions() {
        section = .verifyDonor
    }
}

nonisolated enum StaffLayoutMode: Equatable, Sendable {
    case compact
    case expanded
}

nonisolated enum StaffLayoutPolicy {
    static func mode(forWidth width: Double) -> StaffLayoutMode {
        width >= 700 ? .expanded : .compact
    }
}
