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

    @Binding var selectedTab: MainTab

    @ObservedObject var donorRecordsStore:
        DonorRecordsStore

    let accountProfile: AccountProfile
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
                donorRecordsStore:
                    donorRecordsStore
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
        .tint(
            Color("DonorRed")
        )
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
        isAccountLoading: false,
        accountErrorMessage: nil
    )
}
