//
//  StaffWorkspaceView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import SwiftUI

struct StaffWorkspaceView: View {
    let staff: StaffIdentity
    let onExit: () -> Void

    @State private var navigation = StaffNavigation()
    @State private var showScannerUnavailable = false

    var body: some View {
        GeometryReader { geometry in
            if StaffLayoutPolicy.mode(forWidth: Double(geometry.size.width)) == .expanded {
                HStack(spacing: 0) {
                    StaffSidebar(
                        staff: staff,
                        active: navigation.section,
                        onDashboard: { navigation.showDashboard() },
                        onVerify: { navigation.showVerificationInstructions() },
                        onExit: onExit
                    )
                    .frame(width: 250)
                    Divider()
                    staffContent(for: navigation.section, compact: false)
                }
            } else {
                TabView(selection: selectedTab) {
                    compactPage(for: .dashboard)
                        .tabItem { Label("Dashboard", systemImage: "house.fill") }
                        .tag(StaffSection.dashboard.rawValue)

                    compactPage(for: .verifyDonor)
                        .tabItem { Label("Verify Donor", systemImage: "person.text.rectangle") }
                        .tag(StaffSection.verifyDonor.rawValue)
                }
                .tint(Color("DonorRed"))
            }
        }
        .background(Color("BackgroundPrimary"))
        .alert("Scanner unavailable", isPresented: $showScannerUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The document scanner is not available yet. Please try again later.")
        }
    }

    private var selectedTab: Binding<String> {
        Binding(
            get: { navigation.section.rawValue },
            set: { newValue in
                if newValue == StaffSection.verifyDonor.rawValue {
                    navigation.showVerificationInstructions()
                } else {
                    navigation.showDashboard()
                }
            }
        )
    }

    private func compactPage(for section: StaffSection) -> some View {
        VStack(spacing: 0) {
            if section == .dashboard {
                HStack {
                    Text("Staff Dashboard")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                    Spacer()
                    Button("Sign Out", action: onExit)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color("DonorRed"))
                        .accessibilityHint("Ends this staff session")
                }
                .frame(height: 44)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Color("BackgroundPrimary"))
            } else {
                ScreenNavigationHeader(
                    title: "Verify Donor",
                    onBack: { navigation.showDashboard() }
                )
            }

            staffContent(for: section, compact: true)
        }
    }

    private func staffContent(for section: StaffSection, compact: Bool) -> some View {
        ScreenScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch section {
                case .dashboard:
                    StaffDashboardView(
                        staff: staff,
                        onStartVerification: { navigation.showVerificationInstructions() }
                    )

                case .verifyDonor:
                    StaffScanInstructionsView(
                        onOpenScanner: { showScannerUnavailable = true },
                        onBack: { navigation.showDashboard() }
                    )
                }
            }
            .padding(compact ? 18 : 28)
            .frame(maxWidth: 1020, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(Color("BackgroundPrimary"))
    }
}
