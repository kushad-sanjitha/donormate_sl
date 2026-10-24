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
    private struct RejectingRepository: NotificationInboxRepository {
        enum StorageFailure: Error { case unavailable }

        func load(for userID: String) throws -> [NotificationInboxItem] { [] }

        func save(_ items: [NotificationInboxItem], for userID: String) throws {
            throw StorageFailure.unavailable
        }
    }

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

        #expect(store.items(in: .today, relativeTo: now, calendar: calendar).map(\.id) == ["today"])
        #expect(store.items(in: .earlier, relativeTo: now, calendar: calendar).map(\.id) == ["yesterday"])
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
        #expect(store.items.first(where: { $0.id == "one" })?.isRead == true)
        #expect(store.items.first(where: { $0.id == "two" })?.isRead == false)
    }

    @Test
    func markingReadIsIdempotentAndUnknownIDDoesNothing() {
        let store = NotificationInboxStore(items: [item("one", createdAt: date())])
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
        let allNotificationsAreRead = store.items.allSatisfy { $0.isRead }
        #expect(allNotificationsAreRead)
    }

    @Test
    func invalidAndDuplicateItemsAreDiscarded() {
        let valid = item("same", createdAt: date())
        let blankID = item("  ", createdAt: date())
        let blankTitle = NotificationInboxItem(
            id: "blank-title", kind: .urgentNeed,
            title: "  ", message: "Details", createdAt: date()
        )

        let store = NotificationInboxStore(items: [valid, valid, blankID, blankTitle])
        #expect(store.items.map(\.id) == ["same"])
    }

    @Test
    func replaceItemsReplacesPreviousInbox() {
        let store = NotificationInboxStore(items: [item("old", createdAt: date())])
        store.replaceItems(with: [item("new", createdAt: date(), isRead: true)])

        #expect(store.items.map(\.id) == ["new"])
        #expect(store.unreadCount == 0)
    }

    @Test
    func timeLabelsMatchTodayYesterdayAndOlderSections() {
        let reference = date(2026, 10, 24, hour: 10, minute: 10)
        let locale = Locale(identifier: "en_US")

        #expect(NotificationInboxTimeFormatter.label(
            for: date(2026, 10, 24, hour: 10),
            relativeTo: reference, calendar: calendar, locale: locale
        ) == "10 minutes ago")

        #expect(NotificationInboxTimeFormatter.label(
            for: date(2026, 10, 24, hour: 8),
            relativeTo: reference, calendar: calendar, locale: locale
        ).contains("8:00"))

        #expect(NotificationInboxTimeFormatter.label(
            for: date(2026, 10, 23),
            relativeTo: reference, calendar: calendar, locale: locale
        ) == "Yesterday")

        #expect(NotificationInboxTimeFormatter.label(
            for: date(2026, 9, 11),
            relativeTo: reference, calendar: calendar, locale: locale
        ) == "11 Sep")
    }

    @Test
    func recordedNotificationSurvivesStoreRecreation() throws {
        let suiteName = "DonorMateInboxTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let repository = LocalNotificationInboxRepository(defaults: defaults)
        let original = NotificationInboxStore(repository: repository)
        original.activate(for: "user-one")
        original.record(item("persisted", createdAt: date()))

        let reopened = NotificationInboxStore(repository: repository)
        reopened.activate(for: "user-one")
        #expect(reopened.items.map(\.id) == ["persisted"])
        #expect(reopened.unreadCount == 1)
    }

    @Test
    func readStatePersistsAfterStoreRecreation() throws {
        let suiteName = "DonorMateInboxTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let repository = LocalNotificationInboxRepository(defaults: defaults)
        let original = NotificationInboxStore(repository: repository)
        original.activate(for: "user-one")
        original.record(item("saved-read", createdAt: date()))
        #expect(original.markRead(id: "saved-read"))

        let reopened = NotificationInboxStore(repository: repository)
        reopened.activate(for: "user-one")
        #expect(reopened.items.first?.isRead == true)
        #expect(reopened.unreadCount == 0)
    }

    @Test
    func accountsHaveSeparateNotificationHistory() throws {
        let suiteName = "DonorMateInboxTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationInboxStore(
            repository: LocalNotificationInboxRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        store.record(item("private-one", createdAt: date()))

        store.activate(for: "user-two")
        #expect(store.items.isEmpty)
        store.record(item("private-two", createdAt: date()))

        store.activate(for: "user-one")
        #expect(store.items.map(\.id) == ["private-one"])

        store.activate(for: "user-two")
        #expect(store.items.map(\.id) == ["private-two"])
    }

    @Test
    func signingOutHidesItemsWithoutDeletingSavedHistory() throws {
        let suiteName = "DonorMateInboxTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationInboxStore(
            repository: LocalNotificationInboxRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        store.record(item("restorable", createdAt: date()))

        store.activate(for: nil)
        #expect(store.items.isEmpty)
        #expect(store.activeUserID == nil)

        store.activate(for: "user-one")
        #expect(store.items.map(\.id) == ["restorable"])
    }

    @Test
    func eventsAreIgnoredWithoutAnAuthenticatedUser() {
        let store = NotificationInboxStore()
        store.record(item("anonymous", createdAt: date()))
        #expect(store.items.isEmpty)
    }

    @Test
    func duplicateEventsAreNotAddedTwice() throws {
        let suiteName = "DonorMateInboxTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationInboxStore(
            repository: LocalNotificationInboxRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        let event = item("same-event", createdAt: date())
        store.record(event)
        store.record(event)
        #expect(store.items.count == 1)
    }

    @Test
    func nearbyEventUsesLocationThatTriggeredIt() throws {
        let suiteName = "DonorMateInboxTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = NotificationInboxStore(
            repository: LocalNotificationInboxRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        let location = DonationLocation(
            id: "test-location",
            name: "Test Blood Bank",
            type: .bloodBank,
            latitude: 5.9497,
            longitude: 80.5428,
            detail: "Open today"
        )

        store.recordNearbyAlert(for: location, at: date())
        #expect(store.items.count == 1)
        #expect(store.items.first?.kind == .nearbyAlert)
        #expect(store.items.first?.locationID == "test-location")
        #expect(store.items.first?.createdAt == date())
    }

    @Test
    func invalidStoredJSONDoesNotPretendToBeAnEmptyInbox() throws {
        let suiteName = "DonorMateInboxTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        defaults.set(
            Data("invalid-json".utf8),
            forKey: "DonorMate.notificationInbox.v1.user-one"
        )

        let store = NotificationInboxStore(
            repository: LocalNotificationInboxRepository(defaults: defaults)
        )
        store.activate(for: "user-one")
        #expect(store.items.isEmpty)
        #expect(store.errorMessage != nil)
    }

    @Test
    func rejectedWriteDoesNotPretendNotificationWasSaved() {
        let store = NotificationInboxStore(repository: RejectingRepository())
        store.activate(for: "user-one")
        store.record(item("unsaved", createdAt: date()))

        #expect(store.items.isEmpty)
        #expect(store.errorMessage != nil)
    }
}
