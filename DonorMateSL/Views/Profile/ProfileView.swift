//
//  ProfileView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct ProfileView: View {

    let accountProfile: AccountProfile
    @ObservedObject var donorRecordsStore: DonorRecordsStore
    @ObservedObject var donationLocationStore: DonationLocationStore
    @ObservedObject var savedItemsStore: SavedItemsStore
    @ObservedObject var notificationInboxStore: NotificationInboxStore
    @ObservedObject var currentLocationService: CurrentLocationService
    let isLoading: Bool
    let errorMessage: String?

    var onFindNearby: () -> Void = {}
    var onReturnHome: () -> Void = {}
    var onSignOut: () -> Void = {}

    @State private var showSignOutConfirmation = false
    @State private var showPreparationGuide = false
    @State private var showPostDonationGuide = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Text("Profile")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Color("TextPrimary"))

                        Spacer()

                        if donorRecordsStore.profile != nil {
                            Text(donorRecordsStore.isVerified ? "✓ Donor linked" : "Demo record")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(
                                    donorRecordsStore.isVerified
                                        ? Color("SuccessGreen")
                                        : Color("DonorRed")
                                )
                                .padding(.horizontal, 10)
                                .padding(.vertical, 7)
                                .background(
                                    donorRecordsStore.isVerified
                                        ? Color("SuccessGreenSoft")
                                        : Color("DonorRedSoft")
                                )
                                .clipShape(Capsule())
                        }
                    }

                    Text("Account and preferences")
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 16)
                .background(Color("BackgroundPrimary"))

                ScreenScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                            HStack(spacing: 14) {

                            ZStack {
                                Circle()
                                    .fill(Color("DonorRedSoft"))
                                    .frame(width: 56, height: 56)

                                Text(initials)
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundStyle(Color("DonorRed"))
                            }

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {
                                Text(accountProfile.displayName)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(Color("TextPrimary"))

                                if let donorProfile = donorRecordsStore.profile {
                                    Text("Blood group · \(donorProfile.bloodGroup)")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color("TextSecondary"))

                                    if let count = donorProfile.reportedDonationCount {
                                        Text("\(count) recorded donations")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color("TextSecondary"))
                                    }
                                }

                                Text(accountProfile.email)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color("TextSecondary"))

                                if let maskedNIC =
                                    accountProfile
                                        .maskedNationalIdentityNumber {

                                    Text("NIC \(maskedNIC)")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(Color("TextSecondary"))
                                }
                            }

                            Spacer()
                        }
                        .padding(16)
                        .background(Color("SurfacePrimary"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    Color("BorderPrimary"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )

                        DetailInfoRow(
                            systemImage: "drop.fill",
                            label: "Blood group",
                            value: bloodGroupDisplayName,
                            supportingText: donorRecordsStore.profile == nil
                                ? "Connect your donor record to see this information."
                                : donorRecordsStore.isVerified
                                    ? "From your linked donor record · view only"
                                    : "Demonstration data · not verified",
                            iconForeground: Color("DonorRed")
                        )

                        NavigationLink {
                            NotificationsView(inboxStore: notificationInboxStore)
                        } label: {
                            HomeInfoRow(
                                title: "Notifications",
                                detail: "Donation reminders and relevant alerts",
                                systemImage: "bell.fill",
                                iconBackground: Color("DonorRedSoft"),
                                iconForeground: Color("DonorRed")
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            SavedCampaignsView(
                                savedItemsStore: savedItemsStore,
                                donationLocationStore: donationLocationStore,
                                donorRecordsStore: donorRecordsStore,
                                currentLocationService: currentLocationService
                            )
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "bookmark.fill")
                                    .foregroundStyle(Color("DonorRed"))
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Saved Campaigns")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(Color("TextPrimary"))
                                    Text("Your saved camps and blood banks")
                                        .font(.system(size: 13))
                                        .foregroundStyle(Color("TextSecondary"))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color("TextSecondary"))
                            }
                            .padding(16)
                            .background(Color("SurfacePrimary"))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("BorderPrimary"), lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            SettingsView(
                                onSignOut: onSignOut,
                                isSignOutDisabled: isLoading
                            )
                        } label: {
                            HomeInfoRow(
                                title: "Settings",
                                detail: "Notifications, privacy and app preferences",
                                systemImage: "gearshape.fill",
                                iconBackground: Color("NeutralSoft"),
                                iconForeground: Color("TextSecondary")
                            )
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 8) {
                            guidanceButton("Before Donation") {
                                showPreparationGuide = true
                            }

                            guidanceButton("After Donation") {
                                showPostDonationGuide = true
                            }
                        }

                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 12))
                                .foregroundStyle(Color("DonorRed"))
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }

                        Button {
                            showSignOutConfirmation = true
                        } label: {
                            Group {
                                if isLoading {
                                    ProgressView()
                                        .tint(Color("DonorRed"))
                                } else {
                                    Text("Sign Out")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Color("DonorRed"))
                                }
                            }
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 48
                            )
                            .background(Color("SurfacePrimary"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        Color("DonorRedBorder"),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(
                                RoundedRectangle(cornerRadius: 14)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)

                        Spacer()
                }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
            }
            .background(Color("BackgroundPrimary"))
            .navigationDestination(isPresented: $showPreparationGuide) {
                DonationPreparationGuideView(onFindNearby: {
                    showPreparationGuide = false
                    onFindNearby()
                })
            }
            .navigationDestination(isPresented: $showPostDonationGuide) {
                PostDonationGuideView(onDone: {
                    showPostDonationGuide = false
                    onReturnHome()
                })
            }
            .alert(
                "Sign out of DonorMate?",
                isPresented: $showSignOutConfirmation
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    onSignOut()
                }
            } message: {
                Text(
                    "Your account session will be removed from this device. Any donor information currently held in memory will also be cleared."
                )
            }
        }
        .tabBarContentClearance()
    }

    private func guidanceButton(
        _ title: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
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
    }

    private var bloodGroupDisplayName: String {
        guard let bloodGroup = donorRecordsStore.profile?.bloodGroup else {
            return "Not available"
        }

        switch bloodGroup {
        case "A+": return "A Positive (A+)"
        case "A-": return "A Negative (A-)"
        case "B+": return "B Positive (B+)"
        case "B-": return "B Negative (B-)"
        case "AB+": return "AB Positive (AB+)"
        case "AB-": return "AB Negative (AB-)"
        case "O+": return "O Positive (O+)"
        case "O-": return "O Negative (O-)"
        default: return bloodGroup
        }
    }

    private var initials: String {

        let parts =
            accountProfile.displayName
                .split {
                    $0.isWhitespace
                }

        let value =
            parts
                .prefix(2)
                .compactMap {
                    $0.first
                }
                .map {
                    String($0)
                }
                .joined()
                .uppercased()

        return value.isEmpty
            ? "DM"
            : value
    }
}

#Preview {
    ProfileView(
        accountProfile:
            AccountProfile(
                uid: "preview-user",
                displayName: "Kushad Dissanayake",
                email: "kushad@example.com",
                nationalIdentityNumber:
                    "198554200159"
            ),
        donorRecordsStore: DonorRecordsStore(
            linkState: .linked(profile: DonorDemoData.profile),
            records: DonorDemoData.records
        ),
        donationLocationStore: DonationLocationStore(),
        savedItemsStore: SavedItemsStore(),
        notificationInboxStore: NotificationInboxStore(),
        currentLocationService: CurrentLocationService(),
        isLoading: false,
        errorMessage: nil,
        onSignOut: {
            print("Sign out tapped")
        }
    )
    .environmentObject(NotificationPreferencesStore())
    .environmentObject(AccountSetupStore())
}
