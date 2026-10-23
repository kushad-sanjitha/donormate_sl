//
//  NearbyAlertView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/16/26.
//

import SwiftUI
import MapKit

struct NearbyAlertView: View {

    let location: DonationLocation

    @Environment(\.dismiss) private var dismiss

    @State private var isNearbyAlertEnabled = false
    @State private var isLoadingMonitoringState = true
    @State private var isSavingAlert = false

    private var destinationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }

    private var mapRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: destinationCoordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.015,
                longitudeDelta: 0.015
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
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Location Alert",
                onBack: {
                    dismiss()
                }
            )

            ScrollView {
                VStack(spacing: 0) {

                Map(
                    initialPosition: .region(mapRegion)
                ) {

                    MapCircle(
                        center: destinationCoordinate,
                        radius: 500
                    )
                    .foregroundStyle(
                        Color("InfoBlue")
                            .opacity(0.12)
                    )
                    .stroke(
                        Color("InfoBlue")
                            .opacity(0.55),
                        lineWidth: 2
                    )

                    UserAnnotation()

                    Annotation(
                        location.name,
                        coordinate: destinationCoordinate
                    ) {
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
                    }
                }
                .frame(height: 330)
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
                    .accessibilityLabel("Nearby alert")
                    .disabled(
                        isLoadingMonitoringState ||
                        isSavingAlert
                    )
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
                    Task {
                        await saveLocationAlert()
                    }
                } label: {
                    HStack(spacing: 8) {

                        if isSavingAlert {
                            ProgressView()
                                .tint(.white)
                        }

                        Text(
                            isSavingAlert
                                ? "Saving..."
                                : "Save Location Alert"
                        )
                        .font(
                            .system(
                                size: 15,
                                weight: .bold
                            )
                        )
                    }
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
                .disabled(
                    isLoadingMonitoringState ||
                    isSavingAlert
                )
                .opacity(
                    isLoadingMonitoringState ||
                    isSavingAlert
                        ? 0.6
                        : 1
                )

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
        .task {
            await loadMonitoringState()
        }
    }

    @MainActor
    private func loadMonitoringState() async {

        let isMonitoring =
            await NearbyAlertMonitorService.shared
                .isMonitoring(
                    locationID: location.id
                )

        isNearbyAlertEnabled =
            isMonitoring

        isLoadingMonitoringState =
            false
    }

    @MainActor
    private func saveLocationAlert() async {

        guard isSavingAlert == false else {
            return
        }

        isSavingAlert = true

        if isNearbyAlertEnabled {

            await NearbyAlertMonitorService.shared
                .addAlert(
                    locationID: location.id,
                    latitude: location.latitude,
                    longitude: location.longitude
                )

            print(
                "Nearby alert registered:",
                location.name
            )

        } else {

            await NearbyAlertMonitorService.shared
                .removeAlert(
                    locationID: location.id
                )

            print(
                "Nearby alert removed:",
                location.name
            )
        }

        isSavingAlert = false
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
