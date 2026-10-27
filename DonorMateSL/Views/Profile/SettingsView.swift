//
//  SettingsView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationPreferencesStore: NotificationPreferencesStore

    @State private var showSignOutConfirmation = false

    let onSignOut: () -> Void
    var isSignOutDisabled: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Settings",
                onBack: { dismiss() }
            )

            ScreenScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionHeading("APP PREFERENCES")

                    VStack(spacing: 10) {
                        NavigationLink {
                            NotificationPreferencesView(store: notificationPreferencesStore)
                        } label: {
                            settingsRow(
                                title: "Notifications",
                                detail: "Donation, campaign and urgent-need preferences",
                                showsDisclosure: true
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            PrivacyFaceIDView()
                        } label: {
                            settingsRow(
                                title: "Privacy & Face ID",
                                detail: "Biometric access and privacy information",
                                showsDisclosure: true
                            )
                        }
                        .buttonStyle(.plain)

                        settingsRow(
                            title: "Home Screen Widget",
                            detail: "Current donor-status widget states"
                        )
                    }

                    sectionHeading("DATA")
                        .padding(.top, 18)

                    VStack(spacing: 10) {
                        settingsRow(
                            title: "Donation records",
                            detail: "Updated from the linked service · view only"
                        )

                        settingsRow(
                            title: "Offline information",
                            detail: "Recent donor information available when offline"
                        )

                        settingsRow(
                            title: "Appearance",
                            detail: "System default"
                        )
                    }

                    Button {
                        showSignOutConfirmation = true
                    } label: {
                        Text("Sign Out")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("SurfacePrimary"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color("BorderPrimary"), lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSignOutDisabled)
                    .padding(.top, 20)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .alert(
            "Sign out of DonorMate?",
            isPresented: $showSignOutConfirmation
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                onSignOut()
            }
        } message: {
            Text("Your account session will be removed from this device. Any donor information currently held in memory will also be cleared.")
        }
    }

    private func sectionHeading(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color("TextSecondary"))
            .padding(.bottom, 8)
    }

    private func settingsRow(
        title: String,
        detail: String,
        showsDisclosure: Bool = false
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))

                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showsDisclosure {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color("TextSecondary"))
                    .accessibilityHidden(true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("SurfacePrimary"))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("BorderPrimary"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview("Screen 35 - Settings") {
    NavigationStack {
        SettingsView(onSignOut: {})
    }
    .environmentObject(NotificationPreferencesStore())
    .environmentObject(AccountSetupStore())
}
