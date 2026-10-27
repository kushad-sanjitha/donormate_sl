//
//  AccountSetupStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/27/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct AccountSetupStoreTests {

    @Test
    func firstLoginHasNoSavedLinkOrFaceIDAndRequiresInitialSetup() throws {
        let suite = "donormate.setup.test.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = AccountSetupStore(defaults: defaults)
        store.activate(for: "firebase-user-A")

        #expect(store.linkedDonorRecordID == nil)
        #expect(!store.hasCompletedInitialSetup)
        #expect(!store.faceIDProtectionEnabled)
    }

    @Test
    func restoresSetupLinkedIDAndFaceIDAfterRecreation() throws {
        let suite = "donormate.setup.test.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let initial = AccountSetupStore(defaults: defaults)
        initial.activate(for: "firebase-user-A")
        #expect(initial.rememberLinkedRecordID(" DM-248013 "))
        #expect(initial.setFaceIDProtectionEnabled(true))
        #expect(initial.completeInitialSetup())

        let relaunched = AccountSetupStore(defaults: defaults)
        relaunched.activate(for: "firebase-user-A")

        #expect(relaunched.linkedDonorRecordID == "DM-248013")
        #expect(relaunched.faceIDProtectionEnabled)
        #expect(relaunched.hasCompletedInitialSetup)
    }

    @Test
    func switchingAccountsNeverSharesAnotherAccountsChoices() throws {
        let suite = "donormate.setup.test.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = AccountSetupStore(defaults: defaults)
        store.activate(for: "firebase-user-A")
        #expect(store.rememberLinkedRecordID("DM-248013"))
        #expect(store.setFaceIDProtectionEnabled(true))
        #expect(store.completeInitialSetup())

        store.activate(for: "firebase-user-B")
        #expect(store.linkedDonorRecordID == nil)
        #expect(!store.faceIDProtectionEnabled)
        #expect(!store.hasCompletedInitialSetup)

        #expect(store.completeInitialSetup())
        store.activate(for: "firebase-user-A")
        #expect(store.linkedDonorRecordID == "DM-248013")
        #expect(store.faceIDProtectionEnabled)
        #expect(store.hasCompletedInitialSetup)

        store.activate(for: "firebase-user-B")
        #expect(store.linkedDonorRecordID == nil)
        #expect(!store.faceIDProtectionEnabled)
        #expect(store.hasCompletedInitialSetup)
    }

    @Test
    func signOutClearsInMemoryStateWithoutErasingAccountPreferences() throws {
        let suite = "donormate.setup.test.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = AccountSetupStore(defaults: defaults)
        store.activate(for: "firebase-user-A")
        #expect(store.setFaceIDProtectionEnabled(true))
        #expect(store.completeInitialSetup())

        store.activate(for: nil)
        #expect(store.activeUserID == nil)
        #expect(!store.faceIDProtectionEnabled)
        #expect(!store.hasCompletedInitialSetup)

        store.activate(for: "firebase-user-A")
        #expect(store.faceIDProtectionEnabled)
        #expect(store.hasCompletedInitialSetup)
    }

    @Test
    func unlinkRemovesOnlyLinkedIDNotCompletedSetupOrFaceID() throws {
        let suite = "donormate.setup.test.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = AccountSetupStore(defaults: defaults)
        store.activate(for: "firebase-user-A")
        #expect(store.rememberLinkedRecordID("DM-248013"))
        #expect(store.completeInitialSetup())
        #expect(store.setFaceIDProtectionEnabled(true))

        #expect(store.forgetLinkedRecordID())
        #expect(store.linkedDonorRecordID == nil)
        #expect(store.hasCompletedInitialSetup)
        #expect(store.faceIDProtectionEnabled)
    }

    @Test
    func noAccountAndEmptyRecordIDDoNotPersistData() throws {
        let suite = "donormate.setup.test.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }

        let store = AccountSetupStore(defaults: defaults)
        #expect(!store.rememberLinkedRecordID("DM-248013"))
        #expect(!store.setFaceIDProtectionEnabled(true))

        store.activate(for: "firebase-user-A")
        #expect(!store.rememberLinkedRecordID("  "))
        #expect(store.linkedDonorRecordID == nil)
    }
}
