//
//  NotificationInboxStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import Foundation
import Combine

@MainActor
final class NotificationInboxStore: ObservableObject {
    static let shared = NotificationInboxStore()

    @Published private(set) var items: [NotificationInboxItem]
    @Published private(set) var activeUserID: String?
    @Published private(set) var errorMessage: String?

    private let repository: any NotificationInboxRepository
    private static let maximumItems = 200

    init(
        items: [NotificationInboxItem] = [],
        repository: (any NotificationInboxRepository)? = nil
    ) {
        self.repository = repository ?? LocalNotificationInboxRepository()
        self.items = Self.validUniqueSorted(items)
    }

    func activate(for userID: String?) {
        let cleanID = userID?.trimmingCharacters(in: .whitespacesAndNewlines)
        let nextID = cleanID?.isEmpty == false ? cleanID : nil

        guard activeUserID != nextID || errorMessage != nil else { return }

        activeUserID = nextID
        items = []
        errorMessage = nil

        guard let nextID else { return }

        do {
            items = Self.validUniqueSorted(try repository.load(for: nextID))
        } catch {
            errorMessage = "Notifications could not be loaded on this device."
        }
    }

    var unreadCount: Int {
        items.filter { !$0.isRead }.count
    }

    func items(
        in section: NotificationInboxSection,
        relativeTo date: Date,
        calendar: Calendar = .current
    ) -> [NotificationInboxItem] {
        items.filter { item in
            let isToday = calendar.isDate(item.createdAt, inSameDayAs: date)
            return section == .today ? isToday : !isToday
        }
    }

    func replaceItems(with newItems: [NotificationInboxItem]) {
        _ = persist(Self.validUniqueSorted(newItems))
    }

    func record(_ item: NotificationInboxItem) {
        guard activeUserID != nil,
              !items.contains(where: { $0.id == item.id }) else { return }

        _ = persist(Self.validUniqueSorted(items + [item]))
    }

    func recordNearbyAlert(for location: DonationLocation, at date: Date = Date()) {
        guard activeUserID != nil else { return }

        record(NotificationInboxItem(
            id: "nearby-\(UUID().uuidString)",
            kind: .nearbyAlert,
            title: "Nearby donation location",
            message: "You're near \(location.name).",
            createdAt: date,
            locationID: location.id
        ))
    }

    @discardableResult
    func markRead(id: String) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return false
        }

        guard !items[index].isRead else { return true }
        var updated = items
        updated[index].isRead = true
        return persist(updated)
    }

    func markAllRead() {
        guard unreadCount > 0 else { return }
        let updated = items.map { item in
            var updated = item
            updated.isRead = true
            return updated
        }
        _ = persist(updated)
    }

    @discardableResult
    private func persist(_ updated: [NotificationInboxItem]) -> Bool {
        if let activeUserID {
            do {
                try repository.save(updated, for: activeUserID)
            } catch {
                errorMessage = "Notifications could not be saved on this device."
                return false
            }
        }

        items = updated
        errorMessage = nil
        return true
    }

    private static func validUniqueSorted(
        _ incoming: [NotificationInboxItem]
    ) -> [NotificationInboxItem] {
        var seenIDs = Set<String>()

        return Array(incoming.filter { item in
            let id = item.id.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = item.title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !id.isEmpty, !title.isEmpty else { return false }
            return seenIDs.insert(id).inserted
        }
        .sorted {
            if $0.createdAt == $1.createdAt {
                return $0.id < $1.id
            }
            return $0.createdAt > $1.createdAt
        }.prefix(maximumItems))
    }
}
