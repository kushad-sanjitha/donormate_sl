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
    @Published private(set) var items: [NotificationInboxItem]

    init(items: [NotificationInboxItem] = []) {
        self.items = Self.validUniqueSorted(items)
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
        items = Self.validUniqueSorted(newItems)
    }

    @discardableResult
    func markRead(id: String) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return false
        }

        guard !items[index].isRead else { return true }
        var updated = items
        updated[index].isRead = true
        items = updated
        return true
    }

    func markAllRead() {
        guard unreadCount > 0 else { return }
        items = items.map { item in
            var updated = item
            updated.isRead = true
            return updated
        }
    }

    private static func validUniqueSorted(
        _ incoming: [NotificationInboxItem]
    ) -> [NotificationInboxItem] {
        var seenIDs = Set<String>()

        return incoming.filter { item in
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
        }
    }
}
