//
//  NotificationPreferencesRepository.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import Foundation

@MainActor
protocol NotificationPreferencesRepository {
    func load(for userID: String) throws -> NotificationPreferences
    func save(_ preferences: NotificationPreferences, for userID: String) throws
}

@MainActor
struct LocalNotificationPreferencesRepository: NotificationPreferencesRepository {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(for userID: String) throws -> NotificationPreferences {
        guard let data = defaults.data(forKey: key(for: userID)) else {
            return NotificationPreferences()
        }

        return try JSONDecoder().decode(NotificationPreferences.self, from: data)
    }

    func save(_ preferences: NotificationPreferences, for userID: String) throws {
        let data = try JSONEncoder().encode(preferences)
        defaults.set(data, forKey: key(for: userID))
    }

    private func key(for userID: String) -> String {
        "DonorMate.notificationPreferences.v1.\(userID)"
    }
}
