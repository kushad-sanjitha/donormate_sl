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

    init(preferences: NotificationPreferences = NotificationPreferences()) {
        self.preferences = preferences
    }

    func isEnabled(_ kind: NotificationPreferenceKind) -> Bool {
        preferences.isEnabled(kind)
    }

    func setEnabled(_ enabled: Bool, for kind: NotificationPreferenceKind) {
        guard preferences.isEnabled(kind) != enabled else { return }
        preferences.setEnabled(enabled, for: kind)
    }
}
