//
//  RoutePreviewView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import SwiftUI
import MapKit

struct RoutePreviewView: View {

    let location: DonationLocation

    @Environment(\.dismiss) private var dismiss

    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.04,
                longitudeDelta: 0.04
            )
        )
    }

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

                    Text("Directions")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()
                }
                .frame(minHeight: 46)

                Spacer()
                    .frame(height: 8)

                Map(
                    initialPosition: .region(mapRegion)
                ) {
                    Annotation(
                        location.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.latitude,
                            longitude: location.longitude
                        )
                    ) {
                        ZStack {
                            Circle()
                                .fill(markerForeground)
                                .frame(width: 36, height: 36)

                            Image(systemName: markerSymbol)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(height: 485)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            Color("NeutralBorderStrong"),
                            lineWidth: 1
                        )
                        .allowsHitTesting(false)
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )

                Spacer()
                    .frame(height: 12)

                HStack(
                    alignment: .center,
                    spacing: 12
                ) {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(location.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        Text("Route information pending")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    Text("Driving")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color("InfoBlue"))
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(Color("InfoBlueSoft"))
                        .overlay {
                            Capsule()
                                .stroke(
                                    Color("InfoBlueBorder"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(Capsule())
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
                    color: Color.black.opacity(0.06),
                    radius: 6,
                    x: 0,
                    y: 2
                )

                Spacer()
                    .frame(height: 12)

                Button {
                    print(
                        "Open in Apple Maps tapped:",
                        location.name
                    )
                } label: {
                    Text("Open in Apple Maps")
                        .font(.system(size: 15, weight: .bold))
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
        RoutePreviewView(
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
