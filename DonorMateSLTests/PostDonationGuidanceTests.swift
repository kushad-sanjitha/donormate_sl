//
//  PostDonationGuidanceTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/25/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct PostDonationGuidanceTests {
    @Test
    func postDonationStepsMatchTheApprovedPrototypeInOrder() {
        #expect(DonationGuidanceCatalog.postDonationSteps.map(\.text) == [
            "Rest as advised by the donation centre.",
            "Drink enough fluids after your donation.",
            "Follow the blood bank’s instructions for your dressing or plaster.",
            "Contact qualified staff if you feel unwell or have concerns."
        ])
    }

    @Test
    func postDonationUsesThreeChecksThenOneWarning() {
        #expect(DonationGuidanceCatalog.postDonationSteps.map(\.marker) == [
            .check,
            .check,
            .check,
            .warning
        ])
    }

    @Test
    func allGuidanceIdentifiersAreUniqueAndNonempty() {
        let allSteps = DonationGuidanceCatalog.preparationSteps
            + DonationGuidanceCatalog.postDonationSteps
        let identifiers = allSteps.map(\.id)

        #expect(DonationGuidanceCatalog.postDonationSteps.count == 4)
        #expect(Set(identifiers).count == allSteps.count)
        #expect(allSteps.allSatisfy { !$0.id.isEmpty && !$0.text.isEmpty })
    }
}
