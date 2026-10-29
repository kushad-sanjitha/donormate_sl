//
//  NotificationPermissionService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import Foundation
import UserNotifications
import Combine

enum NotificationPermissionStatus {
    case notDetermined
    case authorized
    case denied
    case provisional
}

@MainActor
final class NotificationPermissionService: ObservableObject {

    @Published private(set) var status: NotificationPermissionStatus = .notDetermined

    private let notificationCenter: UNUserNotificationCenter

    init(
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.notificationCenter = notificationCenter

        refreshStatus()
    }

    func requestPermission() {

        notificationCenter.getNotificationSettings { [weak self] settings in

            guard let self else {
                return
            }

            let authorizationStatus = settings.authorizationStatus

            Task { @MainActor in

                let currentStatus = self.mapAuthorizationStatus(
                    authorizationStatus
                )

                self.status = currentStatus

                guard currentStatus == .notDetermined else {
                    return
                }

                self.requestSystemPermission()
            }
        }
    }

    func refreshStatus() {

        notificationCenter.getNotificationSettings { [weak self] settings in

            guard let self else {
                return
            }

            let authorizationStatus = settings.authorizationStatus

            Task { @MainActor in

                self.status = self.mapAuthorizationStatus(
                    authorizationStatus
                )
            }
        }
    }

    private func requestSystemPermission() {

        notificationCenter.requestAuthorization(
            options: [
                .alert,
                .sound,
                .badge
            ]
        ) { [weak self] _, _ in

            guard let self else {
                return
            }

            Task { @MainActor in
                self.refreshStatus()
            }
        }
    }

    private func mapAuthorizationStatus(
        _ authorizationStatus: UNAuthorizationStatus
    ) -> NotificationPermissionStatus {

        switch authorizationStatus {

        case .notDetermined:
            return .notDetermined

        case .authorized:
            return .authorized

        case .denied:
            return .denied

        case .provisional:
            return .provisional

        case .ephemeral:
            return .authorized

        @unknown default:
            return .denied
        }
    }
}
