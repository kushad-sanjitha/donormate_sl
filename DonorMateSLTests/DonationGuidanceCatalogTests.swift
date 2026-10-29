//
//  DonationGuidanceCatalogTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/25/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct DonationGuidanceCatalogTests {
    @Test
    func preparationStepsMatchTheApprovedPrototypeInOrder() {
        #expect(DonationGuidanceCatalog.preparationSteps.map(\.text) == [
            "Check that the recorded minimum donation interval has passed.",
            "Bring valid identification.",
            "Follow official food, hydration and rest guidance.",
            "Confirm campaign details before travelling.",
            "Ask qualified blood-bank staff if you are unsure about your health or eligibility."
        ])
    }

    @Test
    func preparationUsesFourOrderedNumbersThenOneWarning() {
        #expect(DonationGuidanceCatalog.preparationSteps.map(\.marker) == [
            .number(1),
            .number(2),
            .number(3),
            .number(4),
            .warning
        ])
    }

    @Test
    func guidanceStepsHaveUniqueAndNonemptyIdentifiers() {
        let steps = DonationGuidanceCatalog.preparationSteps
        let identifiers = steps.map(\.id)

        #expect(steps.count == 5)
        #expect(Set(identifiers).count == steps.count)
        #expect(steps.allSatisfy { !$0.id.isEmpty && !$0.text.isEmpty })
    }
}
