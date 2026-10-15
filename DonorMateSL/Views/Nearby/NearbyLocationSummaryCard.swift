//
//  NearbyLocationSummaryCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import SwiftUI

struct NearbyLocationSummaryCard: View {

    let name: String
    let detail: String
    let distanceText: String?
    let type: DonationLocation.LocationType

    var onDetails: () -> Void = {}
    var onDirections: () -> Void = {}

    private var typeTitle: String {
        switch type {
        case .camp:
            return "Camp"

        case .bloodBank:
            return "Blood Bank"
        }
    }

    private var typeForeground: Color {
        switch type {
        case .camp:
            return Color("DonorRed")

        case .bloodBank:
            return Color("InfoBlue")
        }
    }

    private var typeBackground: Color {
        switch type {
        case .camp:
            return Color("DonorRedSoft")

        case .bloodBank:
            return Color("InfoBlueSoft")
        }
    }

    private var supportingText: String {
        guard let distanceText else {
            return detail
        }

        return "\(detail) · \(distanceText)"
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            HStack(
                alignment: .top,
                spacing: 12
            ) {

                Text(name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Spacer()

                Text(typeTitle)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(typeForeground)
                    .padding(.horizontal, 9)
                    .frame(height: 26)
                    .background(typeBackground)
                    .clipShape(Capsule())
            }

            Spacer()
                .frame(height: 5)

            Text(supportingText)
                .font(.system(size: 12))
                .foregroundStyle(Color("TextSecondary"))
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Spacer()
                .frame(height: 14)

            HStack(spacing: 10) {

                Button {
                    onDetails()
                } label: {
                    Text("Details")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 44
                        )
                        .background(Color("SurfacePrimary"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color("BorderPrimary"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)

                Button {
                    onDirections()
                } label: {
                    Text("Directions")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 44
                        )
                        .background(Color("DonorRed"))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
            }
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
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 3
        )
    }
}

#Preview {
    VStack(spacing: 16) {

        NearbyLocationSummaryCard(
            name: "Matara Donation Camp",
            detail: "Sat · 9:00 AM",
            distanceText: "2.3 km",
            type: .camp
        )

        NearbyLocationSummaryCard(
            name: "Matara Blood Bank",
            detail: "Open today",
            distanceText: "1.5 km",
            type: .bloodBank
        )
    }
    .padding(18)
    .background(Color("BackgroundPrimary"))
}
