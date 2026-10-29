//
//  RoutePreviewView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/15/26.
//

import SwiftUI
import CoreLocation
import MapKit

struct RoutePreviewView: View {

    let location: DonationLocation

    @Environment(\.dismiss) private var dismiss

    @StateObject private var currentLocationService =
        CurrentLocationService()

    private let routeDirectionsService =
        RouteDirectionsService()

    @State private var route: MKRoute?
    @State private var isLoadingRoute = false
    @State private var routeErrorMessage: String?

    @State private var cameraPosition: MapCameraPosition

    init(location: DonationLocation) {
        self.location = location

        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.04,
                longitudeDelta: 0.04
            )
        )

        _cameraPosition = State(
            initialValue: .region(initialRegion)
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

    private var routeStatusText: String {
        if isLoadingRoute {
            return "Calculating route..."
        }

        if let route {
            return formattedRouteSummary(
                route
            )
        }

        if routeErrorMessage != nil ||
            currentLocationService.errorMessage != nil {
            return "Unable to calculate route"
        }

        return "Route information pending"
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Directions",
                onBack: {
                    dismiss()
                }
            )

            ScreenScrollView {
                VStack(spacing: 0) {

                Map(
                    position: $cameraPosition
                ) {

                    UserAnnotation()

                    if let route {
                        MapPolyline(
                            route.polyline
                        )
                        .stroke(
                            Color("InfoBlue"),
                            style: StrokeStyle(
                                lineWidth: 6,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                    }

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

                        Text(routeStatusText)
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
                    openInAppleMaps()
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
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            currentLocationService.requestCurrentLocation()
        }
        .onChange(
            of: currentLocationService.currentLocation
        ) { _, newLocation in

            guard let newLocation else {
                return
            }

            calculateRoute(
                from: newLocation
            )
        }
    }

    private func calculateRoute(
        from sourceLocation: CLLocation
    ) {
        guard isLoadingRoute == false else {
            return
        }

        guard route == nil else {
            return
        }

        isLoadingRoute = true
        routeErrorMessage = nil

        Task {
            do {
                let calculatedRoute =
                    try await routeDirectionsService.calculateRoute(
                        from: sourceLocation,
                        to: location
                    )

                route = calculatedRoute
                routeErrorMessage = nil
                isLoadingRoute = false

                fitCamera(
                    to: calculatedRoute
                )

                print(
                    "Route calculated:",
                    calculatedRoute.distance,
                    calculatedRoute.expectedTravelTime
                )

            } catch {
                route = nil
                routeErrorMessage = error.localizedDescription
                isLoadingRoute = false

                print(
                    "Route calculation failed:",
                    error.localizedDescription
                )
            }
        }
    }

    private func formattedRouteSummary(
        _ route: MKRoute
    ) -> String {

        let distanceInKilometres =
            route.distance / 1000

        let minutes =
            max(
                1,
                Int(
                    round(
                        route.expectedTravelTime / 60
                    )
                )
            )

        let distanceText =
            String(
                format: "%.1f km",
                distanceInKilometres
            )

        return "\(distanceText) · about \(minutes) min"
    }

    private func fitCamera(
        to route: MKRoute
    ) {
        let routeRect =
            route.polyline.boundingMapRect

        let horizontalPadding =
            routeRect.size.width * 0.15

        let verticalPadding =
            routeRect.size.height * 0.15

        let paddedRouteRect =
            routeRect.insetBy(
                dx: -horizontalPadding,
                dy: -verticalPadding
            )

        cameraPosition =
            .rect(paddedRouteRect)
    }

    private func openInAppleMaps() {
        let destinationLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let destinationMapItem = MKMapItem(
            location: destinationLocation,
            address: nil
        )

        destinationMapItem.name =
            location.name

        destinationMapItem.openInMaps(
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey:
                    MKLaunchOptionsDirectionsModeDriving
            ]
        )
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
