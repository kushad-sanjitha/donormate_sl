//
//  NotificationPreferencesStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import Foundation
import Combine

@MainActor
final class NotificationPreferencesStore: ObservableObject {
    @Published private(set) var preferences: NotificationPreferences
    @Published private(set) var activeUserID: String?
    @Published private(set) var errorMessage: String?

    private let repository: any NotificationPreferencesRepository

    init(
        preferences: NotificationPreferences = NotificationPreferences(),
        repository: (any NotificationPreferencesRepository)? = nil
    ) {
        self.preferences = preferences
        self.repository = repository ?? LocalNotificationPreferencesRepository()
    }

    func activate(for userID: String?) {
        let trimmedID = userID?.trimmingCharacters(in: .whitespacesAndNewlines)
        let nextID = trimmedID?.isEmpty == false ? trimmedID : nil

        guard activeUserID != nextID || errorMessage != nil else { return }

        activeUserID = nextID
        preferences = NotificationPreferences()
        errorMessage = nil

        guard let nextID else { return }

        do {
            preferences = try repository.load(for: nextID)
        } catch {
            errorMessage = "Notification preferences could not be loaded on this device."
        }
    }

    func isEnabled(_ kind: NotificationPreferenceKind) -> Bool {
        preferences.isEnabled(kind)
    }

    func setEnabled(_ enabled: Bool, for kind: NotificationPreferenceKind) {
        guard preferences.isEnabled(kind) != enabled else { return }

        var updated = preferences
        updated.setEnabled(enabled, for: kind)

        if let activeUserID {
            do {
                try repository.save(updated, for: activeUserID)
            } catch {
                errorMessage = "Notification preferences could not be saved on this device."
                return
            }
        }

        preferences = updated
        errorMessage = nil
    }
}
