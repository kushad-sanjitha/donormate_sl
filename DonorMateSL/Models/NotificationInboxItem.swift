//
//  NotificationInboxItem.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import Foundation

nonisolated enum NotificationInboxKind: String, Equatable, Sendable {
    case urgentNeed
    case donationReady
    case campaignReminder
    case nearbyAlert
}

nonisolated struct NotificationInboxItem: Identifiable, Equatable, Sendable {
    let id: String
    let kind: NotificationInboxKind
    let title: String
    let message: String
    let createdAt: Date
    let locationID: String?
    var isRead: Bool

    init(
        id: String,
        kind: NotificationInboxKind,
        title: String,
        message: String,
        createdAt: Date,
        locationID: String? = nil,
        isRead: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.message = message
        self.createdAt = createdAt
        self.locationID = locationID
        self.isRead = isRead
    }
}

nonisolated enum NotificationInboxSection: CaseIterable, Hashable, Sendable {
    case today
    case earlier

    var title: String {
        switch self {
        case .today: "Today"
        case .earlier: "Earlier"
        }
    }
}

nonisolated enum NotificationInboxTimeFormatter {
    static func label(
        for date: Date,
        relativeTo referenceDate: Date,
        calendar: Calendar = .current,
        locale: Locale = .current
    ) -> String {
        if calendar.isDate(date, inSameDayAs: referenceDate) {
            let minutes = Int(referenceDate.timeIntervalSince(date) / 60)
            if (1..<60).contains(minutes) {
                return minutes == 1 ? "1 minute ago" : "\(minutes) minutes ago"
            }

            let timeFormatter = DateFormatter()
            timeFormatter.calendar = calendar
            timeFormatter.timeZone = calendar.timeZone
            timeFormatter.locale = locale
            timeFormatter.timeStyle = .short
            return timeFormatter.string(from: date)
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: referenceDate),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }

        let dayFormatter = DateFormatter()
        dayFormatter.calendar = calendar
        dayFormatter.timeZone = calendar.timeZone
        dayFormatter.locale = locale
        dayFormatter.dateFormat = "d MMM"
        return dayFormatter.string(from: date)
    }
}
