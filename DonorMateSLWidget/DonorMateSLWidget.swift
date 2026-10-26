//
//  DonorMateSLWidget.swift
//  DonorMateSLWidget
//
//  Created by user300742 on 10/25/26.
//

import SwiftUI
import WidgetKit

nonisolated enum DonorMateWidgetStatus {
    case countdown(daysRemaining: Int, nextPossibleDate: Date)
    case ready(nearbyOpportunities: Int?)
    case urgent(bloodGroup: String, locationName: String, distanceKilometres: Double?)
    case unavailable
}

nonisolated struct DonorMateWidgetEntry: TimelineEntry {
    let date: Date
    let status: DonorMateWidgetStatus
}

nonisolated struct DonorMateWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DonorMateWidgetEntry {
        DonorMateWidgetEntry(date: .now, status: .unavailable)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (DonorMateWidgetEntry) -> Void
    ) {
        let now = Date()
        completion(makeEntry(at: now, snapshot: sharedSnapshot()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<DonorMateWidgetEntry>) -> Void
    ) {
        let now = Date()

        guard let snapshot = sharedSnapshot() else {
            completion(Timeline(
                entries: [DonorMateWidgetEntry(date: now, status: .unavailable)],
                policy: .never
            ))
            return
        }

        switch DonorMateWidgetReadinessResolver.resolve(snapshot, now: now) {
        case .countdown, .ready:
            completion(timeline(for: snapshot, now: now))
        case .unavailable:
            completion(Timeline(
                entries: [DonorMateWidgetEntry(date: now, status: .unavailable)],
                policy: .never
            ))
        }
    }

    private func sharedSnapshot() -> DonorMateWidgetSnapshot? {
        DonorMateWidgetSharedStore()?.load()
    }

    private func makeEntry(
        at date: Date,
        snapshot: DonorMateWidgetSnapshot?
    ) -> DonorMateWidgetEntry {
        let status: DonorMateWidgetStatus

        switch DonorMateWidgetReadinessResolver.resolve(snapshot, now: date) {
        case .countdown(let daysRemaining, let nextPossibleDate):
            status = .countdown(daysRemaining: daysRemaining, nextPossibleDate: nextPossibleDate)
        case .ready:
            status = .ready(nearbyOpportunities: nil)
        case .unavailable:
            status = .unavailable
        }

        return DonorMateWidgetEntry(date: date, status: status)
    }

    private func timeline(
        for snapshot: DonorMateWidgetSnapshot,
        now: Date
    ) -> Timeline<DonorMateWidgetEntry> {
        var entries = [makeEntry(at: now, snapshot: snapshot)]
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let expiry = snapshot.publishedAt.addingTimeInterval(
            DonorMateWidgetReadinessResolver.maximumSnapshotAge + 1
        )

        for offset in 1...8 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today),
                  day > now,
                  day < expiry else { continue }
            entries.append(makeEntry(at: day, snapshot: snapshot))
        }

        if expiry > now {
            entries.append(makeEntry(at: expiry, snapshot: snapshot))
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct DonorMateSLWidget: Widget {
    static let kind = "DonorMateSLStatus"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: DonorMateWidgetProvider()) { entry in
            DonorMateWidgetView(entry: entry)
        }
        .configurationDisplayName("DonorMate Status")
        .description("Donation readiness and verified, relevant urgent needs.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemMedium, widget: {
    DonorMateSLWidget()
}, timeline: {
    DonorMateWidgetEntry(
        date: .now,
        status: .countdown(
            daysRemaining: 12,
            nextPossibleDate: Calendar.current.date(byAdding: .day, value: 12, to: .now) ?? .now
        )
    )
})

#Preview(as: .systemMedium, widget: {
    DonorMateSLWidget()
}, timeline: {
    DonorMateWidgetEntry(date: .now, status: .ready(nearbyOpportunities: 3))
})

#Preview(as: .systemMedium, widget: {
    DonorMateSLWidget()
}, timeline: {
    DonorMateWidgetEntry(
        date: .now,
        status: .urgent(
            bloodGroup: "A+",
            locationName: "Matara Blood Bank",
            distanceKilometres: 2.8
        )
    )
})

