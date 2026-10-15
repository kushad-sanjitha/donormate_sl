//
//  NearbyLocationRow.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import SwiftUI

struct NearbyLocationRow: View {

    let location: DonationLocation
    let distanceText: String?
    let onTap: () -> Void

    private var supportingText: String {
        guard let distanceText else {
            return location.detail
        }

        return "\(location.detail) · \(distanceText)"
    }

    private var iconName: String {
        switch location.type {

        case .camp:
            return "drop.fill"

        case .bloodBank:
            return "cross.case.fill"
        }
    }

    private var iconForeground: Color {
        switch location.type {

        case .camp:
            return Color("DonorRed")

        case .bloodBank:
            return Color("InfoBlue")
        }
    }

    private var iconBackground: Color {
        switch location.type {

        case .camp:
            return Color("DonorRedSoft")

        case .bloodBank:
            return Color("InfoBlueSoft")
        }
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(
                alignment: .center,
                spacing: 12
            ) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackground)
                        .frame(width: 42, height: 42)

                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(iconForeground)
                }
                .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(location.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )

                    Text(supportingText)
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextSecondary"))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                }

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
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 10) {

        NearbyLocationRow(
            location: DonationLocation(
                id: "matara-blood-bank",
                name: "Matara Blood Bank",
                type: .bloodBank,
                latitude: 5.9497,
                longitude: 80.5428,
                detail: "Open today"
            ),
            distanceText: "1.5 km",
            onTap: {
                print("Matara Blood Bank tapped")
            }
        )

        NearbyLocationRow(
            location: DonationLocation(
                id: "walgama-donation-camp",
                name: "Walgama Donation Camp",
                type: .camp,
                latitude: 5.9706,
                longitude: 80.5241,
                detail: "Sun · 8:30 AM"
            ),
            distanceText: "3.8 km",
            onTap: {
                print("Walgama Donation Camp tapped")
            }
        )
    }
    .padding(18)
    .background(Color("BackgroundPrimary"))
}
