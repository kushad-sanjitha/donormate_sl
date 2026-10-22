//
//  ProfileView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct ProfileView: View {

    let accountProfile: AccountProfile
    let isLoading: Bool
    let errorMessage: String?

    var onSignOut: () -> Void = {}

    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(
                    alignment: .leading,
                    spacing: 18
                ) {

                    Text("Profile")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))

                    Text("Account and preferences")
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextSecondary"))

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

                            Text(accountProfile.email)
                                .font(.system(size: 13))
                                .foregroundStyle(Color("TextSecondary"))
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
                .padding(.top, 18)
            }
            .background(Color("BackgroundPrimary"))
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
                email: "kushad@example.com"
            ),
        isLoading: false,
        errorMessage: nil,
        onSignOut: {
            print("Sign out tapped")
        }
    )
}

