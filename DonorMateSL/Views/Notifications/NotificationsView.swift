//
//  NotificationsView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import SwiftUI

struct NotificationsView: View {
    @ObservedObject var inboxStore: NotificationInboxStore
    @Environment(\.dismiss) private var dismiss

    let referenceDate: Date
    let onPreferences: () -> Void
    let onSelect: (NotificationInboxItem) -> Void

    @State private var showingMoreOptions = false
    private let calendar = Calendar.current

    init(
        inboxStore: NotificationInboxStore,
        referenceDate: Date = Date(),
        onPreferences: @escaping () -> Void = {},
        onSelect: @escaping (NotificationInboxItem) -> Void = { _ in }
    ) {
        self.inboxStore = inboxStore
        self.referenceDate = referenceDate
        self.onPreferences = onPreferences
        self.onSelect = onSelect
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Notifications",
                trailingSystemImage: "ellipsis",
                trailingAccessibilityLabel: "Notification options",
                onBack: { dismiss() },
                onTrailingAction: { showingMoreOptions = true }
            )

            ScreenScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if inboxStore.items.isEmpty {
                        NeutralMessageCard(
                            systemImage: "bell",
                            title: "No notifications yet",
                            detail: "Donation reminders and relevant alerts will appear here."
                        )
                        .padding(.bottom, 16)
                    } else {
                        ForEach(NotificationInboxSection.allCases, id: \.self) { section in
                            let notifications = inboxStore.items(
                                in: section,
                                relativeTo: referenceDate,
                                calendar: calendar
                            )

                            if !notifications.isEmpty {
                                sectionView(section, notifications: notifications)
                            }
                        }
                    }

                    Button(action: onPreferences) {
                        Text("Notification Preferences")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("SurfacePrimary"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color("BorderPrimary"), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .confirmationDialog(
            "Notification options",
            isPresented: $showingMoreOptions,
            titleVisibility: .visible
        ) {
            Button("Mark all as read") {
                inboxStore.markAllRead()
            }
            .disabled(inboxStore.unreadCount == 0)
        }
    }

    private func sectionView(
        _ section: NotificationInboxSection,
        notifications: [NotificationInboxItem]
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.title)
                .font(.system(size: 12))
                .foregroundStyle(Color("TextSecondary"))

            LazyVStack(spacing: 10) {
                ForEach(notifications) { notification in
                    notificationCard(notification)
                }
            }
        }
        .padding(.bottom, 16)
    }

    private func notificationCard(_ item: NotificationInboxItem) -> some View {
        Button {
            inboxStore.markRead(id: item.id)
            onSelect(item)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                RoundedRectangle(cornerRadius: 4.5)
                    .fill(item.isRead ? Color.clear : Color("DonorRed"))
                    .frame(width: 9, height: 9)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .multilineTextAlignment(.leading)

                    Text(item.message)
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.leading)

                    Text(NotificationInboxTimeFormatter.label(
                        for: item.createdAt,
                        relativeTo: referenceDate,
                        calendar: calendar
                    ))
                    .font(.system(size: 11))
                    .foregroundStyle(Color("TextSecondary"))
                    .padding(.top, 1)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("SurfacePrimary"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color("BorderPrimary"), lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .accessibilityValue(item.isRead ? "Read" : "Unread")
    }
}

#Preview("Screen 30 - Notifications") {
    let calendar = Calendar.current
    let referenceDate = calendar.startOfDay(for: Date()).addingTimeInterval(10 * 3600 + 10 * 60)
    let yesterday = calendar.date(byAdding: .day, value: -1, to: referenceDate)!
    let earlier = calendar.date(byAdding: .day, value: -43, to: referenceDate)!

    NavigationStack {
        NotificationsView(
            inboxStore: NotificationInboxStore(items: [
                NotificationInboxItem(
                    id: "preview-urgent",
                    kind: .urgentNeed,
                    title: "Urgent A+ blood need nearby",
                    message: "Matara Blood Bank · 2.8 km",
                    createdAt: referenceDate.addingTimeInterval(-600),
                    locationID: "matara-blood-bank"
                ),
                NotificationInboxItem(
                    id: "preview-ready",
                    kind: .donationReady,
                    title: "Waiting period completed",
                    message: "You can now look for a donation opportunity.",
                    createdAt: calendar.startOfDay(for: referenceDate).addingTimeInterval(8 * 3600)
                ),
                NotificationInboxItem(
                    id: "preview-camp",
                    kind: .campaignReminder,
                    title: "Campaign tomorrow",
                    message: "Matara Donation Camp starts at 9:00 AM.",
                    createdAt: yesterday,
                    locationID: "matara-donation-camp",
                    isRead: true
                ),
                NotificationInboxItem(
                    id: "preview-relevant",
                    kind: .urgentNeed,
                    title: "Relevant A+ request",
                    message: "You still have 17 days remaining.",
                    createdAt: earlier,
                    isRead: true
                )
            ]),
            referenceDate: referenceDate
        )
    }
}

#Preview("Screen 30 - Empty") {
    NavigationStack {
        NotificationsView(inboxStore: NotificationInboxStore())
    }
}
