//
//  NearbyAlertView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/16/26.
//

import SwiftUI

struct NearbyAlertView: View {

    let location: DonationLocation

    @Environment(\.dismiss) private var dismiss

    @State private var isNearbyAlertEnabled = true

    private var markerForeground: Color {
        switch location.type {

        case .camp:
            return Color("DonorRed")

        case .bloodBank:
            return Color("InfoBlue")
        }
    }

    private var markerSymbol: String {
        switch location.type {

        case .camp:
            return "drop.fill"

        case .bloodBank:
            return "cross.case.fill"
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                HStack(
                    alignment: .center,
                    spacing: 10
                ) {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 38, height: 38)
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
                    .accessibilityLabel("Back")

                    Text("Location Alert")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()
                }
                .frame(minHeight: 46)

                Spacer()
                    .frame(height: 8)

                ZStack {

                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("NeutralSoft"))

                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            Color("NeutralBorderStrong"),
                            lineWidth: 1
                        )

                    Circle()
                        .fill(
                            Color("InfoBlue")
                                .opacity(0.10)
                        )
                        .overlay {
                            Circle()
                                .stroke(
                                    Color("InfoBlue")
                                        .opacity(0.45),
                                    lineWidth: 2
                                )
                        }
                        .frame(
                            width: 180,
                            height: 180
                        )

                    ZStack {
                        Circle()
                            .fill(markerForeground)
                            .frame(
                                width: 36,
                                height: 36
                            )

                        Image(systemName: markerSymbol)
                            .font(
                                .system(
                                    size: 16,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(.white)
                    }

                    Circle()
                        .fill(Color("InfoBlue"))
                        .frame(
                            width: 16,
                            height: 16
                        )
                        .overlay {
                            Circle()
                                .stroke(
                                    Color("SurfacePrimary"),
                                    lineWidth: 3
                                )
                        }
                        .offset(
                            x: 110,
                            y: 92
                        )
                        .accessibilityHidden(true)
                }
                .frame(height: 330)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )

                Spacer()
                    .frame(height: 16)

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Text("LOCATION-AWARE REMINDER")
                        .font(
                            .system(
                                size: 11,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(Color("DonorRed"))

                    Text(
                        "Notify me when I’m near this location"
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .heavy
                        )
                    )
                    .foregroundStyle(Color("TextPrimary"))
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    Text(
                        "DonorMate can monitor a defined area around this donation location and show a reminder when the device enters the region."
                    )
                    .font(.system(size: 14))
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

                Spacer()
                    .frame(height: 16)

                HStack(
                    alignment: .center,
                    spacing: 12
                ) {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text("Nearby alert")
                            .font(
                                .system(
                                    size: 15,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(Color("TextPrimary"))

                        Text(
                            "\(location.name) · 500 m area"
                        )
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

                    Toggle(
                        "",
                        isOn: $isNearbyAlertEnabled
                    )
                    .labelsHidden()
                    .tint(Color("DonorRed"))
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

                Spacer()
                    .frame(height: 12)

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 17))
                        .foregroundStyle(Color("InfoBlue"))
                        .accessibilityHidden(true)

                    Text(
                        "Location monitoring depends on iOS permission and system limits. You can turn this off at any time."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextPrimary"))
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
                .background(Color("InfoBlueSoft"))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color("InfoBlueBorder"),
                            lineWidth: 1
                        )
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

                Spacer()
                    .frame(height: 14)

                Button {
                    print(
                        "Save Location Alert tapped:",
                        location.name,
                        isNearbyAlertEnabled
                    )
                } label: {
                    Text("Save Location Alert")
                        .font(
                            .system(
                                size: 15,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.white)
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 48
                        )
                        .background(Color("DonorRed"))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 14)
                        )
                }
                .buttonStyle(.plain)

                Spacer()
                    .frame(height: 28)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        NearbyAlertView(
            location: DonationLocation(
                id: "matara-donation-camp",
                name: "Matara Donation Camp",
                type: .camp,
                latitude: 5.9485,
                longitude: 80.5353,
                detail: "Sat · 9:00 AM"
            )
        )
    }
}
