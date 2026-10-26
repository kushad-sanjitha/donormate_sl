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
        completion(DonorMateWidgetEntry(date: .now, status: .unavailable))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<DonorMateWidgetEntry>) -> Void
    ) {

        let entry = DonorMateWidgetEntry(date: .now, status: .unavailable)
        completion(Timeline(entries: [entry], policy: .never))
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
            nextPossibleDate: Calendar.current.date(
                byAdding: .day,
                value: 12,
                to: .now
            ) ?? .now
        )
    )
})

#Preview(as: .systemMedium, widget: {
    DonorMateSLWidget()
}, timeline: {
    DonorMateWidgetEntry(
        date: .now,
        status: .ready(nearbyOpportunities: 3)
    )
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
