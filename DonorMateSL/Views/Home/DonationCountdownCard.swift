//
//  DonationCountdownCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct DonationCountdownCard: View {

    let daysRemaining: Int
    let nextPossibleDate: String
    let progress: Double

    private var safeProgress: Double {
        min(max(progress, 0), 1)
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            Text("Donation status")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(
                    Color.white.opacity(0.78)
                )

            Spacer()
                .frame(height: 3)

            Text("\(daysRemaining) days remaining")
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(.white)

            Spacer()
                .frame(height: 6)

            Text(
                "Next possible date · \(nextPossibleDate)"
            )
            .font(.system(size: 12))
            .foregroundStyle(
                Color.white.opacity(0.78)
            )

            Spacer()
                .frame(height: 14)

            GeometryReader { geometry in
                ZStack(
                    alignment: .leading
                ) {

                    Capsule()
                        .fill(
                            Color.white.opacity(0.22)
                        )
                        .frame(height: 8)

                    Capsule()
                        .fill(Color.white)
                        .frame(
                            width:
                                geometry.size.width
                                * safeProgress,
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            LinearGradient(
                colors: [
                    Color("HomeHeroGradientStart"),
                    Color("DonorRedAccent")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22
            )
        )
        .shadow(
            color:
                Color("DonorRed")
                    .opacity(0.20),
            radius: 12,
            x: 0,
            y: 6
        )
    }
}

#Preview {
    DonationCountdownCard(
        daysRemaining: 24,
        nextPossibleDate: "18 September 2026",
        progress: 0.72
    )
    .padding(18)
    .background(Color("BackgroundPrimary"))
}
