//
//  AccountSetupStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import Foundation
import Combine

nonisolated struct AccountSetupPreferences: Codable, Equatable, Sendable {
    var linkedDonorRecordID: String? = nil
    var hasCompletedInitialSetup = false
    var faceIDProtectionEnabled = false
}

@MainActor
final class AccountSetupStore: ObservableObject {
    @Published private(set) var preferences = AccountSetupPreferences()
    private(set) var activeUserID: String?

    private let defaults: UserDefaults
    private let keyPrefix = "donormate.account.setup.v1."

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var linkedDonorRecordID: String? { preferences.linkedDonorRecordID }
    var hasCompletedInitialSetup: Bool { preferences.hasCompletedInitialSetup }
    var faceIDProtectionEnabled: Bool { preferences.faceIDProtectionEnabled }

    func activate(for userID: String?) {
        let trimmed = userID?.trimmingCharacters(in: .whitespacesAndNewlines)
        let nextID = trimmed?.isEmpty == false ? trimmed : nil
        guard nextID != activeUserID else { return }

        activeUserID = nextID
        guard let nextID,
              let data = defaults.data(forKey: keyPrefix + nextID),
              let decoded = try? JSONDecoder().decode(AccountSetupPreferences.self, from: data) else {
            preferences = AccountSetupPreferences()
            return
        }
        preferences = decoded
    }

    @discardableResult
    func rememberLinkedRecordID(_ recordID: String) -> Bool {
        let normalized = recordID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return false }
        var updated = preferences
        updated.linkedDonorRecordID = normalized
        return persist(updated)
    }

    @discardableResult
    func forgetLinkedRecordID() -> Bool {
        var updated = preferences
        updated.linkedDonorRecordID = nil
        return persist(updated)
    }

    @discardableResult
    func completeInitialSetup() -> Bool {
        var updated = preferences
        updated.hasCompletedInitialSetup = true
        return persist(updated)
    }

    @discardableResult
    func setFaceIDProtectionEnabled(_ enabled: Bool) -> Bool {
        var updated = preferences
        updated.faceIDProtectionEnabled = enabled
        return persist(updated)
    }

    private func persist(_ updated: AccountSetupPreferences) -> Bool {
        guard let activeUserID,
              let encoded = try? JSONEncoder().encode(updated) else { return false }
        defaults.set(encoded, forKey: keyPrefix + activeUserID)
        guard defaults.data(forKey: keyPrefix + activeUserID) == encoded else { return false }
        preferences = updated
        return true
    }
}
