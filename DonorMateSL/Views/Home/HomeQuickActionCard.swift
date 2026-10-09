//
//  HomeQuickActionCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/9/26.
//

import SwiftUI

struct HomeQuickActionCard: View {

    let title: String
        let systemImage: String
        let iconBackground: Color
        let iconForeground: Color

        var body: some View {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBackground)
                        .frame(width: 34, height: 34)

                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(iconForeground)
                }
                .accessibilityHidden(true)

                Spacer()
                    .frame(height: 8)

                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            .padding(12)
            .frame(
                maxWidth: .infinity,
                minHeight: 82,
                alignment: .topLeading
            )
            .background(Color("SurfacePrimary"))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color("BorderPrimary"),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
            .contentShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
    }

    #Preview {
        HStack(spacing: 10) {

            HomeQuickActionCard(
                title: "View Readiness",
                systemImage: "checkmark.circle.fill",
                iconBackground: Color("SuccessGreenSoft"),
                iconForeground: Color("SuccessGreen")
            )

            HomeQuickActionCard(
                title: "Find Nearby",
                systemImage: "map.fill",
                iconBackground: Color("InfoBlueSoft"),
                iconForeground: Color("InfoBlue")
            )
        }
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
