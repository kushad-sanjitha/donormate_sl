//
//  NotificationInboxStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/24/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct NotificationInboxStoreTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func date(
        _ year: Int = 2026,
        _ month: Int = 10,
        _ day: Int = 24,
        hour: Int = 10,
        minute: Int = 0
    ) -> Date {
        calendar.date(from: DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ))!
    }

    private func item(
        _ id: String,
        createdAt: Date,
        isRead: Bool = false
    ) -> NotificationInboxItem {
        NotificationInboxItem(
            id: id,
            kind: .campaignReminder,
            title: "Campaign update",
            message: "Donation opportunity at Matara.",
            createdAt: createdAt,
            isRead: isRead
        )
    }

    @Test
    func inboxStartsEmptyWithoutFakeNotifications() {
        let store = NotificationInboxStore()

        #expect(store.items.isEmpty)
        #expect(store.unreadCount == 0)
    }

    @Test
    func newestNotificationsAppearFirst() {
        let store = NotificationInboxStore(items: [
            item("old", createdAt: date(2026, 10, 22)),
            item("new", createdAt: date(2026, 10, 24)),
            item("middle", createdAt: date(2026, 10, 23))
        ])

        #expect(store.items.map(\.id) == ["new", "middle", "old"])
    }

    @Test
    func todayAndEarlierUseCalendarDays() {
        let now = date(2026, 10, 24, hour: 0, minute: 10)

        let store = NotificationInboxStore(items: [
            item("today", createdAt: date(2026, 10, 24, hour: 0)),
            item("yesterday", createdAt: date(2026, 10, 23, hour: 23))
        ])

        #expect(
            store.items(
                in: .today,
                relativeTo: now,
                calendar: calendar
            ).map(\.id) == ["today"]
        )

        #expect(
            store.items(
                in: .earlier,
                relativeTo: now,
                calendar: calendar
            ).map(\.id) == ["yesterday"]
        )
    }

    @Test
    func openingOneNotificationMarksOnlyThatItemRead() {
        let store = NotificationInboxStore(items: [
            item("one", createdAt: date()),
            item("two", createdAt: date())
        ])

        #expect(store.unreadCount == 2)

        #expect(store.markRead(id: "one"))

        #expect(store.unreadCount == 1)

        #expect(
            store.items.first(where: { $0.id == "one" })?.isRead == true
        )

        #expect(
            store.items.first(where: { $0.id == "two" })?.isRead == false
        )
    }

    @Test
    func markingReadIsIdempotentAndUnknownIDDoesNothing() {
        let store = NotificationInboxStore(items: [
            item("one", createdAt: date())
        ])

        #expect(store.markRead(id: "one"))
        #expect(store.markRead(id: "one"))
        #expect(!store.markRead(id: "missing"))
        #expect(store.unreadCount == 0)
    }

    @Test
    func markAllReadPreservesNotifications() {
        let store = NotificationInboxStore(items: [
            item("one", createdAt: date()),
            item("two", createdAt: date(), isRead: true)
        ])

        store.markAllRead()

        #expect(store.items.count == 2)
        #expect(store.unreadCount == 0)

        let allNotificationsAreRead = store.items.allSatisfy {
            $0.isRead
        }

        #expect(allNotificationsAreRead)
    }

    @Test
    func invalidAndDuplicateItemsAreDiscarded() {
        let valid = item("same", createdAt: date())

        let blankID = item("  ", createdAt: date())

        let blankTitle = NotificationInboxItem(
            id: "blank-title",
            kind: .urgentNeed,
            title: "  ",
            message: "Details",
            createdAt: date()
        )

        let store = NotificationInboxStore(items: [
            valid,
            valid,
            blankID,
            blankTitle
        ])

        #expect(store.items.map(\.id) == ["same"])
    }

    @Test
    func replaceItemsReplacesPreviousInbox() {
        let store = NotificationInboxStore(items: [
            item("old", createdAt: date())
        ])

        store.replaceItems(with: [
            item("new", createdAt: date(), isRead: true)
        ])

        #expect(store.items.map(\.id) == ["new"])
        #expect(store.unreadCount == 0)
    }

    @Test
    func timeLabelsMatchTodayYesterdayAndOlderSections() {
        let reference = date(
            2026,
            10,
            24,
            hour: 10,
            minute: 10
        )

        let locale = Locale(identifier: "en_US")

        #expect(
            NotificationInboxTimeFormatter.label(
                for: date(2026, 10, 24, hour: 10),
                relativeTo: reference,
                calendar: calendar,
                locale: locale
            ) == "10 minutes ago"
        )

        #expect(
            NotificationInboxTimeFormatter.label(
                for: date(2026, 10, 24, hour: 8),
                relativeTo: reference,
                calendar: calendar,
                locale: locale
            ).contains("8:00")
        )

        #expect(
            NotificationInboxTimeFormatter.label(
                for: date(2026, 10, 23),
                relativeTo: reference,
                calendar: calendar,
                locale: locale
            ) == "Yesterday"
        )

        #expect(
            NotificationInboxTimeFormatter.label(
                for: date(2026, 9, 11),
                relativeTo: reference,
                calendar: calendar,
                locale: locale
            ) == "11 Sep"
        )
    }
}
