//
//  AccountRecoveryView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import SwiftUI

struct AccountRecoveryView:
    View {

    @State private var displayName = ""

    let isLoading: Bool
    let errorMessage: String?
    let requiresName: Bool
    let hasPendingProfile: Bool

    let onCompleteName:
        (String) async -> Void

    let onRetrySetup:
        () async -> Void

    let onRetryLoad:
        () async -> Void

    let onSignOut:
        () -> Void

    var body: some View {
        ScrollView {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                Text("ACCOUNT SETUP")
                    .font(
                        .system(
                            size: 12,
                            weight: .heavy
                        )
                    )
                    .foregroundStyle(
                        Color("DonorRed")
                    )

                Text(
                    "Finish your DonorMate account."
                )
                .font(
                    .system(
                        size: 28,
                        weight: .heavy
                    )
                )
                .foregroundStyle(
                    Color("TextPrimary")
                )
                .padding(.top, 10)

                Text(recoveryDescription)
                    .font(.system(size: 14))
                    .foregroundStyle(
                        Color("TextSecondary")
                    )
                    .lineSpacing(3)
                    .padding(.top, 10)

                if requiresName {

                    Text("Full name")
                        .font(
                            .system(
                                size: 12,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            Color("TextPrimary")
                        )
                        .padding(.top, 24)

                    TextField(
                        "Your full name",
                        text: $displayName
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(
                        Color("TextPrimary")
                    )
                    .textInputAutocapitalization(
                        .words
                    )
                    .autocorrectionDisabled()
                    .disabled(isLoading)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(
                        Color("SurfacePrimary")
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 13
                        )
                        .stroke(
                            Color("BorderPrimary"),
                            lineWidth: 1
                        )
                    }
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 13
                        )
                    )
                    .padding(.top, 6)
                }

                if let errorMessage {

                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(
                            Color("DonorRed")
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .padding(.top, 16)
                }

                Button {
                    performPrimaryAction()
                } label: {
                    Group {
                        if isLoading {

                            ProgressView()
                                .tint(.white)

                        } else {

                            Text(primaryButtonTitle)
                                .font(
                                    .system(
                                        size: 15,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(
                                    .white
                                )
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 48
                    )
                    .background(
                        Color("DonorRed")
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )
                }
                .buttonStyle(.plain)
                .disabled(
                    isLoading
                    || (
                        requiresName
                        && displayName
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                )
                .padding(.top, 24)

                Button {
                    onSignOut()
                } label: {
                    Text("Sign Out")
                        .font(
                            .system(
                                size: 14,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            Color("DonorRed")
                        )
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 46
                        )
                }
                .buttonStyle(.plain)
                .disabled(isLoading)
                .padding(.top, 8)
            }
            .padding(.horizontal, 18)
            .padding(.top, 36)
        }
        .background(
            Color("BackgroundPrimary")
        )
    }

    private var recoveryDescription:
        String {

        if requiresName {
            return "Your Firebase account is signed in, but your profile needs your name before setup can continue."
        }

        if hasPendingProfile {
            return "Your Firebase account was created, but the profile could not be saved. Retry the profile setup without creating another account."
        }

        return "Your Firebase session is still valid, but your account profile could not be loaded. Check your connection and try again."
    }

    private var primaryButtonTitle:
        String {

        if requiresName {
            return "Complete Profile"
        }

        if hasPendingProfile {
            return "Retry Profile Setup"
        }

        return "Retry"
    }

    private func performPrimaryAction() {

        guard !isLoading else {
            return
        }

        Task {
            if requiresName {

                let cleanedName =
                    displayName
                        .trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        )

                await onCompleteName(
                    cleanedName
                )

            } else if hasPendingProfile {

                await onRetrySetup()

            } else {

                await onRetryLoad()
            }
        }
    }
}

