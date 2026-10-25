//
//  NotificationDeliveryPolicy.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import Foundation

nonisolated enum NotificationDeliveryPolicy {
    static func preferenceKind(for notificationKind: NotificationInboxKind) -> NotificationPreferenceKind {
        switch notificationKind {
        case .donationReady:
            .donationDateReminders
        case .campaignReminder:
            .savedCampaignReminders
        case .urgentNeed:
            .urgentBloodNeedAlerts
        case .nearbyAlert:
            .locationRelevance
        }
    }

    static func shouldDeliver(
        kind: NotificationInboxKind,
        preferences: NotificationPreferences
    ) -> Bool {
        preferences.isEnabled(preferenceKind(for: kind))
    }
}
