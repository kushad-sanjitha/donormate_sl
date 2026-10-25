//
//  NotificationPreferencesStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/25/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct NotificationPreferencesStoreTests {
    @Test
    func allPreferencesDefaultToEnabled() {
        let store = NotificationPreferencesStore()
        for kind in NotificationPreferenceKind.allCases {
            #expect(store.isEnabled(kind))
        }
    }

    @Test
    func allFourKindsArePresentInPrototypeOrder() {
        #expect(NotificationPreferenceKind.allCases == [
            .donationDateReminders,
            .savedCampaignReminders,
            .urgentBloodNeedAlerts,
            .locationRelevance
        ])

        for kind in NotificationPreferenceKind.allCases {
            #expect(!kind.title.isEmpty)
            #expect(!kind.detail.isEmpty)
        }
    }

    @Test(arguments: NotificationPreferenceKind.allCases)
    func disablingOnePreferenceDoesNotChangeOthers(kind: NotificationPreferenceKind) {
        let store = NotificationPreferencesStore()
        store.setEnabled(false, for: kind)

        #expect(!store.isEnabled(kind))
        for other in NotificationPreferenceKind.allCases where other != kind {
            #expect(store.isEnabled(other))
        }
    }

    @Test(arguments: NotificationPreferenceKind.allCases)
    func aPreferenceCanBeReenabled(kind: NotificationPreferenceKind) {
        let store = NotificationPreferencesStore()
        store.setEnabled(false, for: kind)
        store.setEnabled(true, for: kind)
        #expect(store.isEnabled(kind))
    }

    @Test
    func settingTheSameValueDoesNotChangeOtherPreferences() {
        let store = NotificationPreferencesStore()
        store.setEnabled(false, for: .savedCampaignReminders)
        let before = store.preferences

        store.setEnabled(false, for: .savedCampaignReminders)
        #expect(store.preferences == before)
    }

    @Test
    func modelIsIndependentFromStoreCopy() {
        let store = NotificationPreferencesStore()
        let original = store.preferences

        store.setEnabled(false, for: .urgentBloodNeedAlerts)
        #expect(original.urgentBloodNeedAlerts)
        #expect(!store.preferences.urgentBloodNeedAlerts)
    }

    @Test
    func preferencesCanBeEncodedAndDecoded() throws {
        var preferences = NotificationPreferences()
        preferences.setEnabled(false, for: .donationDateReminders)
        preferences.setEnabled(false, for: .locationRelevance)

        let data = try JSONEncoder().encode(preferences)
        let decoded = try JSONDecoder().decode(NotificationPreferences.self, from: data)
        #expect(decoded == preferences)
    }

    @Test
    func storeUsesProvidedInitialPreferences() {
        var initial = NotificationPreferences()
        initial.setEnabled(false, for: .locationRelevance)

        let store = NotificationPreferencesStore(preferences: initial)
        #expect(!store.isEnabled(.locationRelevance))
        #expect(store.isEnabled(.donationDateReminders))
    }
}
