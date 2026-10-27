//
//  StaffNavigationTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/27/26.
//

import Testing
@testable import DonorMateSL

@MainActor
struct StaffNavigationTests {
    @Test func startsOnDashboard() {
        let state = StaffNavigation()
        #expect(state.section == .dashboard)
    }

    @Test func startScanOpensInstructions() {
        var state = StaffNavigation()
        state.showVerificationInstructions()
        #expect(state.section == .verifyDonor)
    }

    @Test func returningToDashboardResetsSection() {
        var state = StaffNavigation()
        state.showVerificationInstructions()
        state.showDashboard()
        #expect(state.section == .dashboard)
    }

    @Test func compactPhoneWidthUsesCompactNavigation() {
        #expect(StaffLayoutPolicy.mode(forWidth: 390) == .compact)
    }

    @Test func iPadWidthUsesExpandedSidebar() {
        #expect(StaffLayoutPolicy.mode(forWidth: 1024) == .expanded)
    }

    @Test func breakpointIsDeterministic() {
        #expect(StaffLayoutPolicy.mode(forWidth: 699) == .compact)
        #expect(StaffLayoutPolicy.mode(forWidth: 700) == .expanded)
    }
}
