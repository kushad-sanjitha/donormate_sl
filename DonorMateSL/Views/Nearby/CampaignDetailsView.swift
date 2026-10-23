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

    @ObservedObject var donorRecordsStore:
        DonorRecordsStore

    let onDirections: (DonationLocation) -> Void
    let onNearbyAlert: (DonationLocation) -> Void

    @Environment(\.dismiss) private var dismiss

    private var readinessPresentation:
        DonationReadinessPresentation {

        DonationReadinessPresentationBuilder
            .presentation(
                linkState:
                    donorRecordsStore.linkState,
                latestRecord:
                    donorRecordsStore.latestRecord,
                currentDate: Date(),
                calendar: .current
            )
    }

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
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Campaign Details",
                trailingSystemImage: "heart",
                trailingAccessibilityLabel: "Favourite campaign",
                onBack: {
                    dismiss()
                },
                onTrailingAction: {
                    print("Favourite campaign tapped")
                }
            )

            ScrollView {
                VStack(spacing: 0) {

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

                ReadinessStatusCard(
                    presentation:
                        readinessPresentation
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
            donorRecordsStore:
                DonorRecordsStore(
                    linkState:
                        .linked(
                            profile:
                                DonorDemoData.profile
                        ),
                    records:
                        DonorDemoData.records
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
