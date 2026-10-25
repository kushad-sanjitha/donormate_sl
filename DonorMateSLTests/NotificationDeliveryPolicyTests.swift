//
//  NotificationDeliveryPolicyTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/25/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct NotificationDeliveryPolicyTests {
    private enum StorageFailure: Error {
        case unavailable
    }

    private struct FailingLoadRepository: NotificationPreferencesRepository {
        func load(for userID: String) throws -> NotificationPreferences {
            throw StorageFailure.unavailable
        }

        func save(_ preferences: NotificationPreferences, for userID: String) throws {}
    }

    private var notificationKinds: [NotificationInboxKind] {
        [.donationReady, .campaignReminder, .urgentNeed, .nearbyAlert]
    }

    @Test
    func everyNotificationKindMapsToTheCorrectPreference() {
        #expect(NotificationDeliveryPolicy.preferenceKind(for: .donationReady) == .donationDateReminders)
        #expect(NotificationDeliveryPolicy.preferenceKind(for: .campaignReminder) == .savedCampaignReminders)
        #expect(NotificationDeliveryPolicy.preferenceKind(for: .urgentNeed) == .urgentBloodNeedAlerts)
        #expect(NotificationDeliveryPolicy.preferenceKind(for: .nearbyAlert) == .locationRelevance)
    }

    @Test
    func allKindsArePermittedByDefaultPreferences() {
        let preferences = NotificationPreferences()

        for kind in notificationKinds {
            #expect(NotificationDeliveryPolicy.shouldDeliver(kind: kind, preferences: preferences))
        }
    }

    @Test
    func disablingOnePreferenceBlocksOnlyItsCorrespondingNotificationKind() {
        for blockedKind in notificationKinds {
            var preferences = NotificationPreferences()
            let blockedPreference = NotificationDeliveryPolicy.preferenceKind(for: blockedKind)
            preferences.setEnabled(false, for: blockedPreference)

            for otherKind in notificationKinds {
                #expect(NotificationDeliveryPolicy.shouldDeliver(
                    kind: otherKind,
                    preferences: preferences
                ) == (otherKind != blockedKind))
            }
        }
    }

    @Test
    func theSharedDeliveryDecisionTracksChangesToTheAuthenticatedAccountsSettings() throws {
        let suiteName = "DonorMateDeliveryTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let repository = LocalNotificationPreferencesRepository(defaults: defaults)

        let store = NotificationPreferencesStore(repository: repository)
        #expect(!store.shouldDeliverNotification(of: .nearbyAlert))

        store.activate(for: "user-one")
        #expect(store.shouldDeliverNotification(of: .nearbyAlert))

        store.setEnabled(false, for: .locationRelevance)
        #expect(!store.shouldDeliverNotification(of: .nearbyAlert))
        #expect(store.shouldDeliverNotification(of: .urgentNeed))

        let reopened = NotificationPreferencesStore(repository: repository)
        reopened.activate(for: "user-one")
        #expect(!reopened.shouldDeliverNotification(of: .nearbyAlert))

        reopened.setEnabled(true, for: .locationRelevance)
        #expect(reopened.shouldDeliverNotification(of: .nearbyAlert))

        reopened.activate(for: nil)
        #expect(!reopened.shouldDeliverNotification(of: .nearbyAlert))
    }

    @Test
    func unreadablePreferencesFailClosedForNotificationDelivery() {
        let store = NotificationPreferencesStore(repository: FailingLoadRepository())
        store.activate(for: "user-one")

        #expect(store.errorMessage != nil)
        for kind in notificationKinds {
            #expect(!store.shouldDeliverNotification(of: kind))
        }
    }
}
