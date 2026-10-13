//
//  GuidanceItemRow.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct GuidanceItemRow: View {

    enum Style {
        case check
        case number(String)
        case warning
    }

    let text: String
    let style: Style

    private var markerText: String {
        switch style {
        case .check:
            return "✓"
        case .number(let value):
            return value
        case .warning:
            return "!"
        }
    }

    private var markerForeground: Color {
        switch style {
        case .check, .number:
            return Color("SuccessGreen")
        case .warning:
            return Color("WarningAmber")
        }
    }

    private var markerBackground: Color {
        switch style {
        case .check, .number:
            return Color("SuccessGreenSoft")
        case .warning:
            return Color("WarningAmberSoft")
        }
    }

    var body: some View {
        HStack(
            alignment: .center,
            spacing: 12
        ) {

            ZStack {
                Circle()
                    .fill(markerBackground)
                    .frame(width: 22, height: 22)

                Text(markerText)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(markerForeground)
            }
            .accessibilityHidden(true)

            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
        .padding(12)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(Color("SurfacePrimary"))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color("BorderPrimary"),
                    lineWidth: 1
                )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 14)
        )
    }
}

#Preview {
    VStack(spacing: 10) {

        GuidanceItemRow(
            text: "Confirm the current donation requirements.",
            style: .check
        )

        GuidanceItemRow(
            text: "Bring valid identification.",
            style: .number("1")
        )

        GuidanceItemRow(
            text: "Final medical eligibility is always confirmed by authorised blood-bank staff.",
            style: .warning
        )
    }
    .padding(18)
    .background(Color("BackgroundPrimary"))
}
