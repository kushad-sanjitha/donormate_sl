//
//  HomeOpportunityRow.swift
//  DonorMateSL
//
//  Created by user300742 on 10/9/26.
//

import SwiftUI

struct HomeInfoRow: View {

    let title: String
    let detail: String
    let systemImage: String
    let iconBackground: Color
    let iconForeground: Color

    var body: some View {
        HStack(
            alignment: .center,
            spacing: 12
        ) {

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)

                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(iconForeground)
            }
            .accessibilityHidden(true)

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color("TextSecondary"))
                .accessibilityHidden(true)
        }
        .padding(14)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
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
    VStack(spacing: 12) {

        HomeInfoRow(
            title: "Matara Donation Camp",
            detail: "Sat · 9:00 AM · 2.4 km",
            systemImage: "location.fill",
            iconBackground: Color("InfoBlueSoft"),
            iconForeground: Color("InfoBlue")
        )

        HomeInfoRow(
            title: "Donation reminder",
            detail: "Your interval was completed today.",
            systemImage: "bell.fill",
            iconBackground: Color("NeutralSoft"),
            iconForeground: Color("TextSecondary")
        )
    }
    .padding(18)
    .background(Color("BackgroundPrimary"))
}
