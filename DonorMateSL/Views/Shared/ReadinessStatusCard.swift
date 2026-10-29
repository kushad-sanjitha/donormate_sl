//
//  ReadinessStatusCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import SwiftUI

struct ReadinessStatusCard: View {

    let presentation:
        DonationReadinessPresentation

    var body: some View {
        HStack(
            alignment: .top,
            spacing: 4
        ) {
            Text("Your status:")
                .font(
                    .system(
                        size: 12,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color("TextPrimary")
                )

            Text(
                presentation.compactMessage
            )
            .font(.system(size: 12))
            .foregroundStyle(
                Color("TextPrimary")
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .padding(14)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(backgroundColor)
        .overlay {
            RoundedRectangle(
                cornerRadius: 16
            )
            .stroke(
                borderColor,
                lineWidth: 1
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    private var backgroundColor: Color {
        switch presentation.style {

        case .success:
            return Color("SuccessGreenSoft")

        case .warning:
            return Color("WarningAmberSoft")

        case .neutral:
            return Color("SurfacePrimary")
        }
    }

    private var borderColor: Color {
        switch presentation.style {

        case .success:
            return Color("SuccessGreenBorder")

        case .warning,
             .neutral:
            return Color("BorderPrimary")
        }
    }
}

#Preview("Ready") {
    ReadinessStatusCard(
        presentation:
            DonationReadinessPresentation(
                badgeTitle: "Date check",
                title: "Minimum wait completed",
                detail: "Example detail",
                compactMessage: "Recorded minimum waiting period completed. Final eligibility is confirmed by authorised staff.",
                style: .success
            )
    )
    .padding()
}

