//
//  OnboardingPage.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

enum OnboardingVisualType {
    case history
    case countdown
    case nearby
}

struct OnboardingPage: Identifiable {

    let id: Int
    let eyebrow: String
    let title: String
    let description: String
    let buttonTitle: String
    let visualType: OnboardingVisualType

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            eyebrow: "Your donor journey",
            title: "Your donation history, together.",
            description: "View donation records added by the blood bank, including your latest donation and previous history.",
            buttonTitle: "Continue",
            visualType: .history
        ),

        OnboardingPage(
            id: 1,
            eyebrow: "Know when",
            title: "Track your next possible donation date.",
            description: "DonorMate uses your latest recorded donation date to show a clear countdown and useful reminders.",
            buttonTitle: "Continue",
            visualType: .countdown
        ),

        OnboardingPage(
            id: 2,
            eyebrow: "Location-aware donation",
            title: "Find relevant places near you.",
            description: "See nearby camps and blood banks, compare distance, view details, get directions and use location-aware reminders.",
            buttonTitle: "Get Started",
            visualType: .nearby
        )
    ]
}
