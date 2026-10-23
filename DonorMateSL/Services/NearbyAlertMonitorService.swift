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

    private var locationsByID: [String: DonationLocation] = [:]
    private var hasRegisteredLocations = false

    func replaceLocations(_ locations: [DonationLocation]) async {
        let updated = Dictionary(
            locations.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        guard !hasRegisteredLocations || updated != locationsByID else {
            return
        }

        let previous = locationsByID
        let wasRegistered = hasRegisteredLocations
        locationsByID = updated
        hasRegisteredLocations = true

        let monitor = await locationMonitor()
        let existingIdentifiers = await monitor.identifiers

        for identifier in existingIdentifiers {
            guard let id = locationID(from: identifier) else {
                continue
            }

            guard let location = locationsByID[id] else {
                await monitor.remove(identifier)
                continue
            }

            if wasRegistered,
               let old = previous[id],
               old.latitude == location.latitude,
               old.longitude == location.longitude {
                continue
            }

            await monitor.remove(identifier)

            let condition = CLMonitor.CircularGeographicCondition(
                center: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                ),
                radius: Self.alertRadius
            )

            await monitor.add(condition, identifier: identifier)
        }

        if (await monitor.identifiers).isEmpty {
            serviceSession?.invalidate()
            serviceSession = nil
        } else {
            ensureAlwaysServiceSession()
        }
    }

    private var monitorCreationTask:
        Task<CLMonitor, Never>?

    private var serviceSession:
        CLServiceSession?

    private var eventTask:
        Task<Void, Never>?

    private var eventTaskID: UUID?

    private init() {}

    deinit {
        eventTask?.cancel()
        monitorCreationTask?.cancel()
        serviceSession?.invalidate()
    }

    func startObservingEvents() async {

        let monitor =
            await locationMonitor()

        let monitoredIdentifiers =
            await monitor.identifiers

        if monitoredIdentifiers.isEmpty == false {
            ensureAlwaysServiceSession()
        }

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

                    await handle(
                        event,
                        monitor: monitor
                    )
                }

            } catch is CancellationError {
                // Intentional cancellation.
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

        ensureAlwaysServiceSession()

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

        let remainingIdentifiers =
            await monitor.identifiers

        if remainingIdentifiers.isEmpty {
            serviceSession?.invalidate()
            serviceSession = nil
        }
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

    private func ensureAlwaysServiceSession() {

        guard serviceSession == nil else {
            return
        }

        serviceSession =
            CLServiceSession(
                authorization: .always
            )
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
        _ event: CLMonitor.Event,
        monitor: CLMonitor
    ) async {

        guard let locationID =
                locationID(
                    from: event.identifier
                ) else {

            print(
                "Nearby alert event has unknown identifier:",
                event.identifier
            )

            return
        }

        guard let location = locationsByID[locationID] else {

            print(
                "Nearby alert event has unknown location ID:",
                locationID
            )

            return
        }

        let previousState =
            await monitor.record(
                for: event.identifier
            )?.lastEvent.state

        switch event.state {

        case .satisfied:
            guard previousState == .unsatisfied else {

                print(
                    "Nearby alert satisfied ignored:",
                    location.name
                )

                return
            }

            print(
                "Nearby alert condition satisfied:",
                location.name
            )

            do {
                try await NearbyAlertNotificationService.send(
                    for: location
                )

                print(
                    "Nearby alert notification submitted:",
                    location.name
                )

            } catch {
                print(
                    "Nearby alert notification failed:",
                    location.name,
                    error.localizedDescription
                )
            }

        case .unsatisfied:
            print(
                "Nearby alert condition unsatisfied:",
                location.name
            )

        case .unknown:
            print(
                "Nearby alert state unknown:",
                location.name
            )

        case .unmonitored:
            print(
                "Nearby alert unmonitored:",
                location.name
            )

        @unknown default:
            print(
                "Nearby alert state changed:",
                location.name
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

    private func locationID(
        from identifier: String
    ) -> String? {

        guard identifier.hasPrefix("DM") else {
            return nil
        }

        let hexadecimal =
            String(
                identifier.dropFirst(2)
            )

        guard hexadecimal.isEmpty == false else {
            return nil
        }

        guard hexadecimal.count.isMultiple(
            of: 2
        ) else {
            return nil
        }

        var bytes: [UInt8] = []

        var currentIndex =
            hexadecimal.startIndex

        while currentIndex <
                hexadecimal.endIndex {

            let nextIndex =
                hexadecimal.index(
                    currentIndex,
                    offsetBy: 2
                )

            let byteString =
                hexadecimal[
                    currentIndex..<nextIndex
                ]

            guard let byte =
                    UInt8(
                        byteString,
                        radix: 16
                    ) else {
                return nil
            }

            bytes.append(byte)

            currentIndex =
                nextIndex
        }

        return String(
            bytes: bytes,
            encoding: .utf8
        )
    }
}
