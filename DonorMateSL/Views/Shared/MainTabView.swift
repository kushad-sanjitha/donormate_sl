//
//  MainTabView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

enum MainTab: Hashable {
    case home
    case nearby
    case history
    case profile
}

struct MainTabView: View {

    @Environment(\.scenePhase) private var scenePhase

    @Binding var selectedTab: MainTab

    @ObservedObject var donorRecordsStore:
        DonorRecordsStore

    let accountProfile: AccountProfile

    @ObservedObject var donationLocationStore: DonationLocationStore
    @ObservedObject var urgentBloodNeedStore: UrgentBloodNeedStore
    @ObservedObject var savedItemsStore: SavedItemsStore
    @ObservedObject var notificationInboxStore: NotificationInboxStore
    @ObservedObject var locationPermissionService: LocationPermissionService

    @StateObject private var currentLocationService = CurrentLocationService()
    let isAccountLoading: Bool
    let accountErrorMessage: String?

    var onConnectDonorRecord: () -> Void = {}
    var onSignOut: () -> Void = {}

    var body: some View {
        TabView(
            selection: $selectedTab
        ) {

            HomeView(
                donorRecordsStore:
                    donorRecordsStore,
                accountProfile:
                    accountProfile,
                donationLocationStore: donationLocationStore,
                urgentBloodNeedStore: urgentBloodNeedStore,
                savedItemsStore: savedItemsStore,
                notificationInboxStore: notificationInboxStore,
                currentLocationService: currentLocationService,
                onConnectDonorRecord:
                    onConnectDonorRecord,
                onFindNearby: {
                    selectedTab = .nearby
                }
            )
            .tabItem {
                Label(
                    "Home",
                    systemImage:
                        "house.fill"
                )
            }
            .tag(MainTab.home)

            NearbyView(
                donorRecordsStore: donorRecordsStore,
                donationLocationStore: donationLocationStore,
                savedItemsStore: savedItemsStore,
                currentLocationService: currentLocationService
            )
            .tabItem {
                    Label(
                        "Nearby",
                        systemImage:
                            "map.fill"
                    )
                }
                .tag(MainTab.nearby)

            HistoryView(
                donorRecordsStore:
                    donorRecordsStore,
                onConnectDonorRecord:
                    onConnectDonorRecord
            )
            .tabItem {
                Label(
                    "History",
                    systemImage:
                        "clock.arrow.circlepath"
                )
            }
            .tag(MainTab.history)

            ProfileView(
                accountProfile:
                    accountProfile,
                donorRecordsStore: donorRecordsStore,
                donationLocationStore: donationLocationStore,
                savedItemsStore: savedItemsStore,
                notificationInboxStore: notificationInboxStore,
                currentLocationService: currentLocationService,
                isLoading:
                    isAccountLoading,
                errorMessage:
                    accountErrorMessage,
                onSignOut:
                    onSignOut
            )
            .tabItem {
                Label(
                    "Profile",
                    systemImage:
                        "person.fill"
                )
            }
            .tag(MainTab.profile)
        }
        .tint(Color("DonorRed"))
        .onAppear {
            locationPermissionService.refreshStatus()
            if locationPermissionService.status == .authorized {
                currentLocationService.requestCurrentLocation()
            } else {
                currentLocationService.clearCurrentLocation()
            }
        }
        .onChange(of: locationPermissionService.status) { _, status in
            if status == .authorized {
                currentLocationService.requestCurrentLocation()
            } else {
                currentLocationService.clearCurrentLocation()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                locationPermissionService.refreshStatus()
                if locationPermissionService.status == .authorized {
                    currentLocationService.requestCurrentLocation()
                } else {
                    currentLocationService.clearCurrentLocation()
                }
            }
        }
    }
}

#Preview {
    MainTabView(
        selectedTab:
            .constant(.home),
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
        accountProfile:
            AccountProfile(
                uid: "preview-user",
                displayName: "Kushad Dissanayake",
                email: "kushad@example.com"
            ),
        donationLocationStore: DonationLocationStore(),
        urgentBloodNeedStore: UrgentBloodNeedStore(),
        savedItemsStore: SavedItemsStore(),
        notificationInboxStore: NotificationInboxStore(),
        locationPermissionService: LocationPermissionService(),
        isAccountLoading: false,
        accountErrorMessage: nil
    )
}
