//
//  NearbyAlertNotificationService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/19/26.
//

import Foundation
import UserNotifications

nonisolated enum NearbyAlertNotificationService {

    static func send(
        for location: DonationLocation
    ) async throws {

        let content =
            UNMutableNotificationContent()

        content.title =
            "DonorMate"

        content.body =
            "You're near \(location.name)"

        content.sound =
            .default

        content.userInfo = [
            "locationID": location.id
        ]

        let request =
            UNNotificationRequest(
                identifier: notificationIdentifier(
                    for: location.id
                ),
                content: content,
                trigger: nil
            )

        try await UNUserNotificationCenter.current()
            .add(request)
    }

    private static func notificationIdentifier(
        for locationID: String
    ) -> String {

        "nearby-alert-\(locationID)"
    }
}
