//
//  DonationGuidanceCatalog.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import Foundation

nonisolated struct DonationGuidanceStep: Identifiable, Equatable, Sendable {
    nonisolated enum Marker: Equatable, Sendable {
        case number(Int)
        case check
        case warning
    }

    let id: String
    let text: String
    let marker: Marker
}

nonisolated enum DonationGuidanceCatalog {
    static let preparationSteps: [DonationGuidanceStep] = [
        DonationGuidanceStep(
            id: "donation-interval",
            text: "Check that the recorded minimum donation interval has passed.",
            marker: .number(1)
        ),
        DonationGuidanceStep(
            id: "identification",
            text: "Bring valid identification.",
            marker: .number(2)
        ),
        DonationGuidanceStep(
            id: "food-hydration-rest",
            text: "Follow official food, hydration and rest guidance.",
            marker: .number(3)
        ),
        DonationGuidanceStep(
            id: "campaign-details",
            text: "Confirm campaign details before travelling.",
            marker: .number(4)
        ),
        DonationGuidanceStep(
            id: "ask-qualified-staff",
            text: "Ask qualified blood-bank staff if you are unsure about your health or eligibility.",
            marker: .warning
        )
    ]
}
