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

    var onConnectDonorRecord: () -> Void = {}

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem {
                    Label(
                        "Home",
                        systemImage: "house.fill"
                    )
                }
                .tag(MainTab.home)

            NearbyView()
                .tabItem {
                    Label(
                        "Nearby",
                        systemImage: "map.fill"
                    )
                }
                .tag(MainTab.nearby)

            HistoryView(
                onConnectDonorRecord: onConnectDonorRecord
            )
            .tabItem {
                Label(
                    "History",
                    systemImage: "clock.arrow.circlepath"
                )
            }
            .tag(MainTab.history)

            ProfileView()
                .tabItem {
                    Label(
                        "Profile",
                        systemImage: "person.fill"
                    )
                }
                .tag(MainTab.profile)
        }
        .tint(Color("DonorRed"))
    }
}

#Preview {
    MainTabView(
        selectedTab: .constant(.home)
    )
}
