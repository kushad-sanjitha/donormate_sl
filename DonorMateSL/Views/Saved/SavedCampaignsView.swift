//
//  SavedCampaignsView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/24/26.
//

import SwiftUI

struct SavedCampaignsView: View {
    @ObservedObject var savedItemsStore: SavedItemsStore
    @ObservedObject var donationLocationStore: DonationLocationStore
    @ObservedObject var donorRecordsStore: DonorRecordsStore
    @ObservedObject var currentLocationService: CurrentLocationService

    @Environment(\.dismiss) private var dismiss
    @State private var directionsLocationID: String?
    @State private var alertLocationID: String?

    private var savedLocations: [DonationLocation] {
        donationLocationStore.locations
            .filter { savedItemsStore.isSaved($0.id) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private var missingLocationIDs: [String] {
        let known = Set(donationLocationStore.locations.map(\.id))
        return savedItemsStore.savedLocationIDs.subtracting(known).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(title: "Saved Campaigns", onBack: { dismiss() })

            ScreenScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if savedItemsStore.isLoading {
                        ProgressView("Loading saved locations…")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 36)
                    } else if savedItemsStore.savedLocationIDs.isEmpty {
                        NeutralMessageCard(
                            systemImage: "bookmark",
                            title: "No saved locations yet",
                            detail: "Save a donation camp or blood bank to find it here later."
                        )
                    } else {
                        ForEach(savedLocations) { location in
                            savedLocationCard(location)
                        }

                        ForEach(missingLocationIDs, id: \.self) { locationID in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Saved location unavailable")
                                    .font(.system(size: 16, weight: .bold))
                                Text("This location is no longer in the current catalog.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color("TextSecondary"))
                                removeButton(for: locationID)
                            }
                            .savedCampaignCardStyle()
                        }
                    }

                    if let error = savedItemsStore.errorMessage {
                        HStack(spacing: 12) {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundStyle(Color("DonorRed"))
                            Spacer()
                            Button("Retry") {
                                Task {
                                    await savedItemsStore.activate(
                                        for: savedItemsStore.activeUserID
                                    )
                                }
                            }
                            .font(.system(size: 13, weight: .semibold))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 18)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $directionsLocationID) { locationID in
            if let location = donationLocationStore.location(for: locationID) {
                RoutePreviewView(location: location)
            } else {
                ContentUnavailableView("Location unavailable", systemImage: "mappin.slash")
            }
        }
        .navigationDestination(item: $alertLocationID) { locationID in
            if let location = donationLocationStore.location(for: locationID) {
                NearbyAlertView(location: location)
            } else {
                ContentUnavailableView("Location unavailable", systemImage: "mappin.slash")
            }
        }
    }

    private func savedLocationCard(_ location: DonationLocation) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack {
                Text(location.type == .camp ? "SAVED CAMP" : "SAVED BLOOD BANK")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color("DonorRed"))
                Spacer()
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(Color("DonorRed"))
            }

            Text(location.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color("TextPrimary"))

            Text(locationDetail(location))
                .font(.system(size: 13))
                .foregroundStyle(Color("TextSecondary"))

            HStack(spacing: 12) {
                NavigationLink {
                    destination(for: location)
                } label: {
                    Text(location.type == .camp ? "Open campaign ›" : "Open blood bank ›")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color("DonorRed"))
                }
                .buttonStyle(.plain)

                Spacer()
                removeButton(for: location.id)
            }
        }
        .savedCampaignCardStyle()
    }

    private func removeButton(for id: String) -> some View {
        Button("Remove") {
            Task { await savedItemsStore.remove(locationID: id) }
        }
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(Color("TextSecondary"))
        .disabled(savedItemsStore.isSaving)
    }

    @ViewBuilder
    private func destination(for location: DonationLocation) -> some View {
        switch location.type {
        case .camp:
            CampaignDetailsView(
                location: location,
                donorRecordsStore: donorRecordsStore,
                currentLocationService: currentLocationService,
                isSaved: savedItemsStore.isSaved(location.id),
                onToggleSave: { selected in
                    Task { await savedItemsStore.toggle(locationID: selected.id) }
                },
                onDirections: { directionsLocationID = $0.id },
                onNearbyAlert: { alertLocationID = $0.id }
            )
        case .bloodBank:
            BloodBankDetailsView(
                location: location,
                donorRecordsStore: donorRecordsStore,
                currentLocationService: currentLocationService,
                onDirections: { directionsLocationID = $0.id },
                onNearbyAlert: { alertLocationID = $0.id }
            )
        }
    }

    private func locationDetail(_ location: DonationLocation) -> String {
        guard let currentLocation = currentLocationService.currentLocation else {
            return location.detail
        }
        let distance = LocationDistanceCalculator.formattedDistance(
            from: currentLocation, to: location
        )
        return "\(location.detail) · \(distance)"
    }
}

private struct SavedCampaignCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("SurfacePrimary"))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color("BorderPrimary"), lineWidth: 1)
            }
    }
}

private extension View {
    func savedCampaignCardStyle() -> some View {
        modifier(SavedCampaignCardStyle())
    }
}

#Preview {
    NavigationStack {
        SavedCampaignsView(
            savedItemsStore: SavedItemsStore(),
            donationLocationStore: DonationLocationStore(),
            donorRecordsStore: DonorRecordsStore(),
            currentLocationService: CurrentLocationService()
        )
    }
}

