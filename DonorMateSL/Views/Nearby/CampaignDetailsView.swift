//
//  CampaignDetailsView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import SwiftUI
import MapKit

struct CampaignDetailsView: View {

    let location: DonationLocation
    let onDirections: (DonationLocation) -> Void
    let onNearbyAlert: (DonationLocation) -> Void

    @Environment(\.dismiss) private var dismiss

    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.025,
                longitudeDelta: 0.025
            )
        )
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

                    Text("Campaign Details")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Button {
                        print("Favourite campaign tapped")
                    } label: {
                        Image(systemName: "heart")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 38, height: 38)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Favourite campaign")
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
                                .fill(Color("DonorRed"))
                                .frame(width: 34, height: 34)

                            Image(systemName: "drop.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .frame(height: 205)
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
                    .frame(height: 14)

                Text("Donation Camp")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color("DonorRed"))
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color("DonorRedSoft"))
                    .overlay {
                        Capsule()
                            .stroke(
                                Color("DonorRedBorder"),
                                lineWidth: 1
                            )
                    }
                    .clipShape(Capsule())
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Spacer()
                    .frame(height: 7)

                Text(location.name)
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(Color("TextPrimary"))
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Spacer()
                    .frame(height: 4)

                Text(
                    "Saturday, 26 September · 9:00 AM–3:00 PM"
                )
                .font(.system(size: 12))
                .foregroundStyle(Color("TextSecondary"))
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
                    .frame(height: 13)

                DetailInfoRow(
                    systemImage: "mappin",
                    label: "Venue",
                    value: "Matara Town Hall",
                    supportingText: "2.4 km away",
                    iconForeground: Color("TextSecondary")
                )

                Spacer()
                    .frame(height: 10)

                DetailInfoRow(
                    systemImage: "cross.case.fill",
                    label: "Organised by",
                    value: "Matara Blood Bank",
                    iconForeground: Color("TextSecondary")
                )

                Spacer()
                    .frame(height: 12)

                HStack(
                    alignment: .top,
                    spacing: 4
                ) {
                    Text("Your status:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Text("You can donate again in 24 days.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextPrimary"))
                }
                .padding(14)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(Color("WarningAmberSoft"))
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
                    .frame(height: 14)

                HStack(spacing: 8) {

                    Button {
                        onDirections(location)
                    } label: {
                        Text("Directions")
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

                    Button {
                        print("Save tapped")
                    } label: {
                        Text("Save")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 48
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
                    .buttonStyle(.plain)
                }

                Spacer()
                    .frame(height: 10)

                Button {
                    onNearbyAlert(location)
                } label: {
                    Text("Notify Me When Nearby")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("DonorRed"))
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 48
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
        CampaignDetailsView(
            location: DonationLocation(
                id: "matara-donation-camp",
                name: "Matara Donation Camp",
                type: .camp,
                latitude: 5.9485,
                longitude: 80.5353,
                detail: "Sat · 9:00 AM"
            ),
            onDirections: { location in
                print(
                    "Directions tapped:",
                    location.name
                )
            },
            onNearbyAlert: { location in
                print(
                    "Nearby alert tapped:",
                    location.name
                )
            }
        )
    }
}
