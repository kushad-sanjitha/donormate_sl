//
//  NotificationPreferences.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import Foundation

nonisolated enum NotificationPreferenceKind: String, CaseIterable, Identifiable, Codable, Sendable {
    case donationDateReminders
    case savedCampaignReminders
    case urgentBloodNeedAlerts
    case locationRelevance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .donationDateReminders: "Donation-date reminders"
        case .savedCampaignReminders: "Saved campaign reminders"
        case .urgentBloodNeedAlerts: "Urgent blood-need alerts"
        case .locationRelevance: "Location relevance"
        }
    }

    var detail: String {
        switch self {
        case .donationDateReminders: "Countdown and possible-date updates"
        case .savedCampaignReminders: "Remind me before saved campaigns"
        case .urgentBloodNeedAlerts: "Relevant to the linked blood group"
        case .locationRelevance: "Use location when deciding what is nearby"
        }
    }
}

nonisolated struct NotificationPreferences: Codable, Equatable, Sendable {
    var donationDateReminders = true
    var savedCampaignReminders = true
    var urgentBloodNeedAlerts = true
    var locationRelevance = true

    func isEnabled(_ kind: NotificationPreferenceKind) -> Bool {
        switch kind {
        case .donationDateReminders: donationDateReminders
        case .savedCampaignReminders: savedCampaignReminders
        case .urgentBloodNeedAlerts: urgentBloodNeedAlerts
        case .locationRelevance: locationRelevance
        }
    }

    mutating func setEnabled(_ enabled: Bool, for kind: NotificationPreferenceKind) {
        switch kind {
        case .donationDateReminders: donationDateReminders = enabled
        case .savedCampaignReminders: savedCampaignReminders = enabled
        case .urgentBloodNeedAlerts: urgentBloodNeedAlerts = enabled
        case .locationRelevance: locationRelevance = enabled
        }
    }
}
