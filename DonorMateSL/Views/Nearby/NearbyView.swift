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

    private enum NearbyMode {
        case map
        case list
    }

    private enum NearbyRoute: Hashable {
        case details(String)
        case route(String)
        case alert(String)
    }

    @State private var navigationPath: [NearbyRoute] = []

    @State private var selectedMode: NearbyMode = .map
    @State private var selectedFilter: NearbyFilter = .all
    @State private var selectedLocation: DonationLocation?

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

    private var locations: [DonationLocation] {
        DonationLocationCatalog.locations
    }

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

    private var modeButtonTitle: String {
        switch selectedMode {

        case .map:
            return "List"

        case .list:
            return "Map"
        }
    }

    var body: some View {
        NavigationStack(
            path: $navigationPath
        ) {
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
                        switchMode()
                    } label: {
                        Text(modeButtonTitle)
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

                switch selectedMode {

                case .map:
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
                                    navigationPath.append(
                                        .details(
                                            selectedLocation.id
                                        )
                                    )
                                },
                                onDirections: {
                                    navigationPath.append(
                                        .route(
                                            selectedLocation.id
                                        )
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

                case .list:
                    ScrollView {
                        VStack(spacing: 10) {

                            ForEach(filteredLocations) { location in
                                NearbyLocationRow(
                                    location: location,
                                    distanceText: formattedDistance(
                                        to: location
                                    ),
                                    onTap: {
                                        navigationPath.append(
                                            .details(
                                                location.id
                                            )
                                        )
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                }
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
                for: NearbyRoute.self
            ) { route in
                destination(
                    for: route
                )
            }
        }
    }

    @ViewBuilder
    private func destination(
        for route: NearbyRoute
    ) -> some View {

        switch route {

        case .details(let locationID):
            if let location =
                DonationLocationCatalog.location(
                    for: locationID
                ) {

                switch location.type {

                case .camp:
                    CampaignDetailsView(
                        location: location,
                        onDirections: { location in
                            navigationPath.append(
                                .route(
                                    location.id
                                )
                            )
                        },
                        onNearbyAlert: { location in
                            navigationPath.append(
                                .alert(
                                    location.id
                                )
                            )
                        }
                    )

                case .bloodBank:
                    BloodBankDetailsView(
                        location: location,
                        onDirections: { location in
                            navigationPath.append(
                                .route(
                                    location.id
                                )
                            )
                        },
                        onNearbyAlert: { location in
                            navigationPath.append(
                                .alert(
                                    location.id
                                )
                            )
                        }
                    )
                }
            }

        case .route(let locationID):
            if let location =
                DonationLocationCatalog.location(
                    for: locationID
                ) {

                RoutePreviewView(
                    location: location
                )
            }

        case .alert(let locationID):
            if let location =
                DonationLocationCatalog.location(
                    for: locationID
                ) {

                NearbyAlertView(
                    location: location
                )
            }
        }
    }

    private func switchMode() {
        switch selectedMode {

        case .map:
            selectedMode = .list
            selectedLocation = nil

        case .list:
            selectedMode = .map
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

        return LocationDistanceCalculator
            .formattedDistance(
                from: userLocation,
                to: location
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
