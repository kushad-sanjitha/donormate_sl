//
//  BloodBankDetailsView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import SwiftUI
import MapKit

struct BloodBankDetailsView: View {

    let location: DonationLocation

    @ObservedObject var donorRecordsStore: DonorRecordsStore
    @ObservedObject var currentLocationService: CurrentLocationService

    private var distanceText: String {
        guard let userLocation = currentLocationService.currentLocation else {
            return "Distance unavailable without location access"
        }
        return "\(LocationDistanceCalculator.formattedDistance(from: userLocation, to: location)) from your location"
    }

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
                title: "Blood Bank",
                trailingSystemImage: "heart",
                trailingAccessibilityLabel: "Favourite blood bank",
                onBack: {
                    dismiss()
                },
                onTrailingAction: {
                    print("Favourite blood bank tapped")
                }
            )

            ScreenScrollView {
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
                                .fill(Color("InfoBlue"))
                                .frame(width: 34, height: 34)

                            Image(systemName: "cross.case.fill")
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

                Text("Blood Bank")
                    .font(.system(size: 12, weight: .bold))
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

                Text(distanceText)
                .font(.system(size: 12))
                .foregroundStyle(Color("TextSecondary"))
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
                    .frame(height: 13)

                DetailInfoRow(
                    systemImage: "clock",
                    label: "Listed hours",
                    value: location.openingHours ?? "Hours unavailable",
                    iconForeground: Color("TextSecondary")
                )

                Spacer()
                    .frame(height: 10)

                DetailInfoRow(
                    systemImage: "phone.fill",
                    label: "Contact",
                    value: location.contact ?? "Contact unavailable",
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

                Button {
                    onDirections(location)
                } label: {
                    Text("Get Directions")
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
                    .frame(height: 10)

                Button {
                    onNearbyAlert(location)
                } label: {
                    Text("Notify Me When Nearby")
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
        BloodBankDetailsView(
            location: DonationLocation(
                id: "matara-blood-bank",
                name: "Matara Blood Bank",
                type: .bloodBank,
                latitude: 5.9497,
                longitude: 80.5428,
                detail: "Open today"
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
            currentLocationService: CurrentLocationService(),
            onDirections: { location in
                print(
                    "Get Directions tapped:",
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
