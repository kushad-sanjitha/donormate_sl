//
//  DonorMateWidgetView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/26/26.
//

import SwiftUI
import WidgetKit

struct DonorMateWidgetView: View {
    let entry: DonorMateWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text("DonorMate")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(WidgetPalette.textPrimary)

                Spacer()

                statusIndicator
            }

            Spacer(minLength: 8)

            Text(headline)
                .font(.system(size: 25, weight: .heavy))
                .foregroundStyle(WidgetPalette.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Text(detail)
                .font(.system(size: 12))
                .foregroundStyle(WidgetPalette.textSecondary)
                .lineLimit(2)
                .padding(.top, 5)

            if let footer {
                Text(footer)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(WidgetPalette.donorRed)
                    .lineLimit(1)
                    .padding(.top, 7)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [surfaceColor, .white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        switch entry.status {
        case .countdown:
            Image(systemName: "drop.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WidgetPalette.donorRed)
                .frame(width: 34, height: 34)
                .background(WidgetPalette.redSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))

        case .ready:
            statusPill("Ready", foreground: WidgetPalette.green, background: WidgetPalette.greenSoft)

        case .urgent:
            statusPill("Urgent", foreground: WidgetPalette.donorRed, background: WidgetPalette.redSoft)

        case .unavailable:
            Image(systemName: "drop.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(WidgetPalette.donorRed)
                .frame(width: 34, height: 34)
                .background(WidgetPalette.redSoft)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func statusPill(
        _ title: String,
        foreground: Color,
        background: Color
    ) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(background)
            .clipShape(Capsule())
    }

    private var headline: String {
        switch entry.status {
        case .countdown(let daysRemaining, _):
            return daysRemaining == 1 ? "1 day remaining" : "\(daysRemaining) days remaining"
        case .ready:
            return "Ready to donate"
        case .urgent(let bloodGroup, _, _):
            return "\(bloodGroup) needed nearby"
        case .unavailable:
            return "Your donor status"
        }
    }

    private var detail: String {
        switch entry.status {
        case .countdown(_, let nextPossibleDate):
            return "Next possible date · \(nextPossibleDate.formatted(.dateTime.day().month(.abbreviated)))"

        case .ready(let nearbyOpportunities):
            guard let count = nearbyOpportunities else {
                return "Explore nearby donation opportunities"
            }
            return count == 1 ? "1 nearby opportunity" : "\(count) nearby opportunities"

        case .urgent(_, let locationName, let distanceKilometres):
            guard let distanceKilometres else { return locationName }
            return "\(locationName) · \(distanceKilometres.formatted(.number.precision(.fractionLength(1)))) km"

        case .unavailable:
            return "Open DonorMate to view your donation information."
        }
    }

    private var footer: String? {
        switch entry.status {
        case .ready:
            return "Find nearby in DonorMate"
        case .urgent:
            return "View details in DonorMate"
        case .countdown, .unavailable:
            return nil
        }
    }

    private var surfaceColor: Color {
        switch entry.status {
        case .ready:
            return WidgetPalette.greenSoft
        case .urgent:
            return WidgetPalette.redSoft
        case .countdown, .unavailable:
            return .white
        }
    }
}

private enum WidgetPalette {
    static let donorRed = Color(red: 217.0 / 255, green: 45.0 / 255, blue: 32.0 / 255)
    static let redSoft = Color(red: 255.0 / 255, green: 244.0 / 255, blue: 242.0 / 255)
    static let green = Color(red: 2.0 / 255, green: 122.0 / 255, blue: 72.0 / 255)
    static let greenSoft = Color(red: 240.0 / 255, green: 253.0 / 255, blue: 244.0 / 255)
    static let textPrimary = Color(red: 16.0 / 255, green: 24.0 / 255, blue: 40.0 / 255)
    static let textSecondary = Color(red: 102.0 / 255, green: 112.0 / 255, blue: 133.0 / 255)
}
