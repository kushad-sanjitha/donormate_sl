//
//  OnboardingPageTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/20/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct OnboardingPageTests {

    @Test
    func onboardingContainsThreePages() {

        #expect(
            OnboardingPage.pages.count == 3
        )
    }

    @Test
    func onboardingPageIdentifiersAreUnique() {

        let identifiers =
            OnboardingPage.pages.map(
                \.id
            )

        #expect(
            Set(identifiers).count ==
                identifiers.count
        )
    }

    @Test
    func onboardingPagesHaveExpectedOrder() {

        let identifiers =
            OnboardingPage.pages.map(
                \.id
            )

        #expect(
            identifiers == [0, 1, 2]
        )
    }

    @Test
    func historyPageHasExpectedContent() throws {

        let page =
            try #require(
                OnboardingPage.pages.first {
                    $0.id == 0
                }
            )

        #expect(
            page.eyebrow ==
                "Your donor journey"
        )

        #expect(
            page.title ==
                "Your donation history, together."
        )

        #expect(
            page.description ==
                "View donation records added by the blood bank, including your latest donation and previous history."
        )

        #expect(
            page.buttonTitle ==
                "Continue"
        )

        switch page.visualType {
        case .history:
            break

        default:
            Issue.record(
                "Expected history visual type"
            )
        }
    }

    @Test
    func countdownPageHasExpectedContent() throws {

        let page =
            try #require(
                OnboardingPage.pages.first {
                    $0.id == 1
                }
            )

        #expect(
            page.eyebrow ==
                "Know when"
        )

        #expect(
            page.title ==
                "Track your next possible donation date."
        )

        #expect(
            page.description ==
                "DonorMate uses your latest recorded donation date to show a clear countdown and useful reminders."
        )

        #expect(
            page.buttonTitle ==
                "Continue"
        )

        switch page.visualType {
        case .countdown:
            break

        default:
            Issue.record(
                "Expected countdown visual type"
            )
        }
    }

    @Test
    func nearbyPageHasExpectedContent() throws {

        let page =
            try #require(
                OnboardingPage.pages.first {
                    $0.id == 2
                }
            )

        #expect(
            page.eyebrow ==
                "Location-aware donation"
        )

        #expect(
            page.title ==
                "Find relevant places near you."
        )

        #expect(
            page.description ==
                "See nearby camps and blood banks, compare distance, view details, get directions and use location-aware reminders."
        )

        #expect(
            page.buttonTitle ==
                "Get Started"
        )

        switch page.visualType {
        case .nearby:
            break

        default:
            Issue.record(
                "Expected nearby visual type"
            )
        }
    }

    @Test
    func onboardingButtonsHaveCorrectTitles() {

        let buttonTitles =
            OnboardingPage.pages.map(
                \.buttonTitle
            )

        #expect(
            buttonTitles == [
                "Continue",
                "Continue",
                "Get Started"
            ]
        )
    }

    @Test
    func allOnboardingPagesHaveRequiredText() {

        for page in
            OnboardingPage.pages {

            #expect(
                !page.eyebrow
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !page.title
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !page.description
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )

            #expect(
                !page.buttonTitle
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
            )
        }
    }
}
