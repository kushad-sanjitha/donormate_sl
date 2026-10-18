//
//  NearbyAlertMonitorService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/17/26.
//

import Foundation
import CoreLocation

actor NearbyAlertMonitorService {

    static let shared =
        NearbyAlertMonitorService()

    private static let monitorName =
        "DonorMateNearbyAlerts"

    private static let alertRadius:
        CLLocationDistance = 500

    private var monitor: CLMonitor?

    private var monitorCreationTask:
        Task<CLMonitor, Never>?

    private var eventTask:
        Task<Void, Never>?

    private var eventTaskID: UUID?

    private init() {}

    deinit {
        eventTask?.cancel()
        monitorCreationTask?.cancel()
    }

    func startObservingEvents() async {

        let monitor =
            await locationMonitor()

        guard eventTask == nil else {
            return
        }

        let taskID = UUID()

        eventTaskID = taskID

        eventTask = Task {
            do {
                for try await event in await monitor.events {

                    guard Task.isCancelled == false else {
                        break
                    }

                    handle(event)
                }

            } catch is CancellationError {

            } catch {

                guard Task.isCancelled == false else {
                    eventObservationDidEnd(
                        taskID: taskID
                    )

                    return
                }

                print(
                    "Nearby alert monitor event error:",
                    error.localizedDescription
                )
            }

            eventObservationDidEnd(
                taskID: taskID
            )
        }
    }

    func stopObservingEvents() {

        eventTask?.cancel()

        eventTask = nil
        eventTaskID = nil
    }

    func addAlert(
        locationID: String,
        latitude: Double,
        longitude: Double
    ) async {

        let monitor =
            await locationMonitor()

        let coordinate =
            CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )

        let condition =
            CLMonitor.CircularGeographicCondition(
                center: coordinate,
                radius: Self.alertRadius
            )

        let identifier =
            alertIdentifier(
                for: locationID
            )

        await monitor.add(
            condition,
            identifier: identifier
        )
    }

    func removeAlert(
        locationID: String
    ) async {

        let monitor =
            await locationMonitor()

        let identifier =
            alertIdentifier(
                for: locationID
            )

        await monitor.remove(
            identifier
        )
    }

    func isMonitoring(
        locationID: String
    ) async -> Bool {

        let monitor =
            await locationMonitor()

        let identifier =
            alertIdentifier(
                for: locationID
            )

        let record =
            await monitor.record(
                for: identifier
            )

        return record != nil
    }

    private func locationMonitor() async
        -> CLMonitor {

        if let monitor {
            return monitor
        }

        if let monitorCreationTask {
            return await monitorCreationTask.value
        }

        let creationTask =
            Task<CLMonitor, Never> {
                await CLMonitor(
                    Self.monitorName
                )
            }

        monitorCreationTask =
            creationTask

        let createdMonitor =
            await creationTask.value

        monitor =
            createdMonitor

        monitorCreationTask =
            nil

        return createdMonitor
    }

    private func eventObservationDidEnd(
        taskID: UUID
    ) {

        guard eventTaskID == taskID else {
            return
        }

        eventTask = nil
        eventTaskID = nil
    }

    private func handle(
        _ event: CLMonitor.Event
    ) {

        switch event.state {

        case .satisfied:
            print(
                "Nearby alert condition satisfied:",
                event.identifier
            )

        case .unsatisfied:
            print(
                "Nearby alert condition unsatisfied:",
                event.identifier
            )

        case .unknown:
            print(
                "Nearby alert state unknown:",
                event.identifier
            )

        case .unmonitored:
            print(
                "Nearby alert unmonitored:",
                event.identifier
            )

        @unknown default:
            print(
                "Nearby alert state changed:",
                event.identifier
            )
        }
    }

    private func alertIdentifier(
        for locationID: String
    ) -> String {

        let encodedID =
            locationID.utf8
                .map {
                    String(
                        format: "%02X",
                        $0
                    )
                }
                .joined()

        return "DM\(encodedID)"
    }
}
