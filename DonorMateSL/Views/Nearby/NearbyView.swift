//
//  NearbyView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI
import MapKit
import Foundation

struct NearbyView: View {

    private let locations: [DonationLocation] = [
        DonationLocation(
            id: "matara-donation-camp",
            name: "Matara Donation Camp",
            type: .camp,
            latitude: 5.9485,
            longitude: 80.5353,
            detail: "Sat · 9:00 AM"
        ),
        DonationLocation(
            id: "matara-blood-bank",
            name: "Matara Blood Bank",
            type: .bloodBank,
            latitude: 5.9497,
            longitude: 80.5428,
            detail: "Open today"
        ),
        DonationLocation(
            id: "walgama-donation-camp",
            name: "Walgama Donation Camp",
            type: .camp,
            latitude: 5.9706,
            longitude: 80.5241,
            detail: "Sun · 8:30 AM"
        )
    ]

    @State private var selectedFilter: NearbyFilter = .all
    @State private var selectedLocation: DonationLocation?
    @State private var detailsLocation: DonationLocation?

    @StateObject private var locationPermissionService =
        LocationPermissionService()

    @StateObject private var currentLocationService =
        CurrentLocationService()

    @State private var hasCenteredOnUser = false

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 5.9549,
                longitude: 80.5550
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.08,
                longitudeDelta: 0.08
            )
        )
    )

    private var filteredLocations: [DonationLocation] {
        switch selectedFilter {

        case .all:
            return locations

        case .camps:
            return locations.filter {
                $0.type == .camp
            }

        case .bloodBanks:
            return locations.filter {
                $0.type == .bloodBank
            }
        }
    }

    private var isShowingDetails: Binding<Bool> {
        Binding(
            get: {
                detailsLocation != nil
            },
            set: { isPresented in
                if isPresented == false {
                    detailsLocation = nil
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                HStack(
                    alignment: .center,
                    spacing: 12
                ) {

                    Text("Nearby")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Button {
                        print("Nearby list tapped")
                    } label: {
                        Text("List")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .padding(.horizontal, 12)
                            .frame(height: 32)
                            .background(Color("SurfacePrimary"))
                            .overlay {
                                Capsule()
                                    .stroke(
                                        Color("BorderPrimary"),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                    .frame(height: 10)

                NearbyFilterControl(
                    selectedFilter: selectedFilter,
                    onFilterChanged: { newFilter in
                        applyFilter(newFilter)
                    }
                )

                Spacer()
                    .frame(height: 10)

                ZStack(
                    alignment: .bottom
                ) {

                    Map(position: $cameraPosition) {

                        UserAnnotation()

                        ForEach(filteredLocations) { location in
                            Annotation(
                                location.name,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                )
                            ) {
                                Button {
                                    selectedLocation = location
                                } label: {
                                    locationMarker(
                                        for: location
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )

                    if let selectedLocation {
                        NearbyLocationSummaryCard(
                            name: selectedLocation.name,
                            detail: selectedLocation.detail,
                            distanceText: formattedDistance(
                                to: selectedLocation
                            ),
                            type: selectedLocation.type,
                            onDetails: {
                                detailsLocation = selectedLocation
                            },
                            onDirections: {
                                print(
                                    "Directions tapped:",
                                    selectedLocation.name
                                )
                            }
                        )
                        .padding(12)
                    }
                }
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
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .top
            )
            .background(Color("BackgroundPrimary"))
            .onAppear {
                locationPermissionService.refreshStatus()

                if locationPermissionService.status == .authorized {
                    currentLocationService.requestCurrentLocation()
                }
            }
            .onChange(
                of: locationPermissionService.status
            ) { _, newStatus in

                if newStatus == .authorized {
                    currentLocationService.requestCurrentLocation()
                }
            }
            .onChange(
                of: currentLocationService.currentLocation
            ) { _, newLocation in

                guard let newLocation else {
                    return
                }

                guard hasCenteredOnUser == false else {
                    return
                }

                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: newLocation.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.08,
                            longitudeDelta: 0.08
                        )
                    )
                )

                hasCenteredOnUser = true
            }
            .navigationDestination(
                isPresented: isShowingDetails
            ) {
                if let detailsLocation {

                    switch detailsLocation.type {

                    case .camp:
                        CampaignDetailsView(
                            location: detailsLocation
                        )

                    case .bloodBank:
                        BloodBankDetailsView(
                            location: detailsLocation
                        )
                    }
                }
            }
        }
    }

    private func applyFilter(
        _ newFilter: NearbyFilter
    ) {
        selectedFilter = newFilter

        if let selectedLocation,
           isLocation(
               selectedLocation,
               includedIn: newFilter
           ) == false {
            self.selectedLocation = nil
        }
    }

    @ViewBuilder
    private func locationMarker(
        for location: DonationLocation
    ) -> some View {

        switch location.type {

        case .camp:
            ZStack {
                Circle()
                    .fill(Color("DonorRed"))
                    .frame(width: 34, height: 34)

                Image(systemName: "drop.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }

        case .bloodBank:
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

    private func formattedDistance(
        to location: DonationLocation
    ) -> String? {

        guard let userLocation =
                currentLocationService.currentLocation else {
            return nil
        }

        let donationLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let distanceInMetres =
            userLocation.distance(
                from: donationLocation
            )

        let distanceInKilometres =
            distanceInMetres / 1000

        return String(
            format: "%.1f km",
            distanceInKilometres
        )
    }

    private func isLocation(
        _ location: DonationLocation,
        includedIn filter: NearbyFilter
    ) -> Bool {

        switch filter {

        case .all:
            return true

        case .camps:
            return location.type == .camp

        case .bloodBanks:
            return location.type == .bloodBank
        }
    }
}

#Preview {
    NearbyView()
}
