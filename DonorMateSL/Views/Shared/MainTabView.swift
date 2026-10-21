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

    var onConnectDonorRecord: () -> Void = {}

    var body: some View {
        TabView(
            selection: $selectedTab
        ) {

            HomeView(
                donorRecordsStore:
                    donorRecordsStore,
                onConnectDonorRecord:
                    onConnectDonorRecord
            )
            .tabItem {
                Label(
                    "Home",
                    systemImage:
                        "house.fill"
                )
            }
            .tag(MainTab.home)

            NearbyView()
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

            ProfileView()
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
            )
    )
}
