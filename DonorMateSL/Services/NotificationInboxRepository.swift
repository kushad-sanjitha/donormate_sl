//
//  NotificationInboxRepository.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import Foundation

@MainActor
protocol NotificationInboxRepository {
    func load(for userID: String) throws -> [NotificationInboxItem]
    func save(_ items: [NotificationInboxItem], for userID: String) throws
}

@MainActor
struct LocalNotificationInboxRepository: NotificationInboxRepository {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(for userID: String) throws -> [NotificationInboxItem] {
        guard let data = defaults.data(forKey: key(for: userID)) else {
            return []
        }

        return try JSONDecoder().decode([NotificationInboxItem].self, from: data)
    }

    func save(_ items: [NotificationInboxItem], for userID: String) throws {
        let data = try JSONEncoder().encode(items)
        defaults.set(data, forKey: key(for: userID))
    }

    private func key(for userID: String) -> String {
        "DonorMate.notificationInbox.v1.\(userID)"
    }
}
