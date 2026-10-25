//
//  NotificationPreferencesPersistenceTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/25/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct NotificationPreferencesPersistenceTests {
    private enum StorageError: Error {
        case unavailable
    }

    private struct RejectingSaveRepository: NotificationPreferencesRepository {
        func load(for userID: String) throws -> NotificationPreferences {
            NotificationPreferences()
        }

        func save(_ preferences: NotificationPreferences, for userID: String) throws {
            throw StorageError.unavailable
        }
    }

    private func isolatedDefaults() throws -> (UserDefaults, String) {
        let suiteName = "DonorMatePreferencesTests.\(UUID().uuidString)"
        return (try #require(UserDefaults(suiteName: suiteName)), suiteName)
    }

    @Test
    func aNewAccountStartsWithEveryPreferenceEnabled() throws {
        let (defaults, suiteName) = try isolatedDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationPreferencesStore(
            repository: LocalNotificationPreferencesRepository(defaults: defaults)
        )
        store.activate(for: "user-one")

        #expect(store.activeUserID == "user-one")
        #expect(store.errorMessage == nil)
        for kind in NotificationPreferenceKind.allCases {
            #expect(store.isEnabled(kind))
        }
    }

    @Test
    func savedPreferencesSurviveStoreRecreation() throws {
        let (defaults, suiteName) = try isolatedDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let repository = LocalNotificationPreferencesRepository(defaults: defaults)

        let first = NotificationPreferencesStore(repository: repository)
        first.activate(for: "user-one")
        first.setEnabled(false, for: .savedCampaignReminders)
        first.setEnabled(false, for: .locationRelevance)

        let reopened = NotificationPreferencesStore(repository: repository)
        reopened.activate(for: "user-one")

        #expect(!reopened.isEnabled(.savedCampaignReminders))
        #expect(!reopened.isEnabled(.locationRelevance))
        #expect(reopened.isEnabled(.donationDateReminders))
        #expect(reopened.isEnabled(.urgentBloodNeedAlerts))
        #expect(reopened.errorMessage == nil)
    }

    @Test
    func usersKeepIndependentPreferences() throws {
        let (defaults, suiteName) = try isolatedDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationPreferencesStore(
            repository: LocalNotificationPreferencesRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        store.setEnabled(false, for: .donationDateReminders)

        store.activate(for: "user-two")
        #expect(store.isEnabled(.donationDateReminders))
        store.setEnabled(false, for: .urgentBloodNeedAlerts)

        store.activate(for: "user-one")
        #expect(!store.isEnabled(.donationDateReminders))
        #expect(store.isEnabled(.urgentBloodNeedAlerts))

        store.activate(for: "user-two")
        #expect(store.isEnabled(.donationDateReminders))
        #expect(!store.isEnabled(.urgentBloodNeedAlerts))
    }

    @Test
    func signingOutHidesSettingsButDoesNotEraseThem() throws {
        let (defaults, suiteName) = try isolatedDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationPreferencesStore(
            repository: LocalNotificationPreferencesRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        store.setEnabled(false, for: .urgentBloodNeedAlerts)

        store.activate(for: nil)
        #expect(store.activeUserID == nil)
        #expect(store.preferences == NotificationPreferences())

        store.activate(for: "user-one")
        #expect(!store.isEnabled(.urgentBloodNeedAlerts))
    }

    @Test
    func blankUserIDDoesNotLoadAnotherAccountsSettings() throws {
        let (defaults, suiteName) = try isolatedDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationPreferencesStore(
            repository: LocalNotificationPreferencesRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        store.setEnabled(false, for: .locationRelevance)
        store.activate(for: "   ")

        #expect(store.activeUserID == nil)
        #expect(store.isEnabled(.locationRelevance))
    }

    @Test
    func invalidSavedJSONReportsAnError() throws {
        let (defaults, suiteName) = try isolatedDefaults()
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(
            Data("invalid-json".utf8),
            forKey: "DonorMate.notificationPreferences.v1.user-one"
        )

        let store = NotificationPreferencesStore(
            repository: LocalNotificationPreferencesRepository(defaults: defaults)
        )
        store.activate(for: "user-one")

        #expect(store.errorMessage != nil)
        #expect(store.preferences == NotificationPreferences())
    }

    @Test
    func failedSaveDoesNotPretendChangesWereSaved() {
        let store = NotificationPreferencesStore(repository: RejectingSaveRepository())
        store.activate(for: "user-one")

        store.setEnabled(false, for: .savedCampaignReminders)

        #expect(store.isEnabled(.savedCampaignReminders))
        #expect(store.errorMessage != nil)
    }

    @Test
    func previewCanStillToggleWithoutAnAuthenticatedAccount() {
        let store = NotificationPreferencesStore()
        store.setEnabled(false, for: .locationRelevance)

        #expect(store.activeUserID == nil)
        #expect(!store.isEnabled(.locationRelevance))
        #expect(store.errorMessage == nil)
    }
}
