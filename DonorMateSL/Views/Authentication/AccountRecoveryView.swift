//
//  AccountRecoveryView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import SwiftUI

struct AccountRecoveryView: View {

    @State private var displayName: String
    @State private var nationalIdentityNumber = ""
    @State private var validationErrorMessage: String?

    let isLoading: Bool
    let errorMessage: String?
    let requiresName: Bool
    let requiresNationalIdentityNumber: Bool
    let hasPendingProfile: Bool

    let onCompleteProfile:
        (String, String) async -> Void

    let onRetrySetup:
        () async -> Void

    let onRetryLoad:
        () async -> Void

    let onSignOut:
        () -> Void

    init(
        initialDisplayName: String?,
        isLoading: Bool,
        errorMessage: String?,
        requiresName: Bool,
        requiresNationalIdentityNumber: Bool,
        hasPendingProfile: Bool,
        onCompleteProfile:
            @escaping (String, String) async -> Void,
        onRetrySetup:
            @escaping () async -> Void,
        onRetryLoad:
            @escaping () async -> Void,
        onSignOut:
            @escaping () -> Void
    ) {
        _displayName = State(
            initialValue:
                initialDisplayName ?? ""
        )

        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.requiresName = requiresName
        self.requiresNationalIdentityNumber =
            requiresNationalIdentityNumber
        self.hasPendingProfile =
            hasPendingProfile
        self.onCompleteProfile =
            onCompleteProfile
        self.onRetrySetup = onRetrySetup
        self.onRetryLoad = onRetryLoad
        self.onSignOut = onSignOut
    }

    private var displayedErrorMessage: String? {
        validationErrorMessage
        ?? errorMessage
    }

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
                    fieldLabel("Full name")
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

                if requiresNationalIdentityNumber {
                    fieldLabel("NIC number")
                        .padding(.top, 18)

                    TextField(
                        "12 digits or old NIC ending V/X",
                        text: $nationalIdentityNumber
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(
                        Color("TextPrimary")
                    )
                    .textInputAutocapitalization(
                        .characters
                    )
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
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

                    Text(
                        "Your NIC is saved to your private account profile and is used later to verify that a donor record belongs to this account."
                    )
                    .font(.system(size: 11))
                    .foregroundStyle(
                        Color("TextSecondary")
                    )
                    .lineSpacing(2)
                    .padding(.top, 8)
                }

                if let displayedErrorMessage {

                    Text(displayedErrorMessage)
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
                .disabled(isLoading)
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

    private var recoveryDescription: String {

        if requiresNationalIdentityNumber {
            return "Your Firebase session is valid, but your account needs its NIC identity before donor-linked information can be accessed."
        }

        if requiresName {
            return "Your Firebase account is signed in, but your profile needs your name before setup can continue."
        }

        if hasPendingProfile {
            return "Your Firebase account was created, but the profile could not be saved. Retry the profile setup without creating another account."
        }

        return "Your Firebase session is still valid, but your account profile could not be loaded. Check your connection and try again."
    }

    private var primaryButtonTitle: String {

        if requiresName
            || requiresNationalIdentityNumber {
            return "Complete Profile"
        }

        if hasPendingProfile {
            return "Retry Profile Setup"
        }

        return "Retry"
    }

    private func fieldLabel(
        _ title: String
    ) -> some View {

        Text(title)
            .font(
                .system(
                    size: 12,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                Color("TextPrimary")
            )
    }

    private func performPrimaryAction() {

        guard !isLoading else {
            return
        }

        if requiresName
            || requiresNationalIdentityNumber {

            let cleanedName =
                displayName
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )

            guard !cleanedName.isEmpty else {
                validationErrorMessage =
                    "Enter your full name."
                return
            }

            let cleanedNIC =
                NationalIdentityNumberValidator
                    .normalized(
                        nationalIdentityNumber
                    )

            guard NationalIdentityNumberValidator
                    .isValid(cleanedNIC) else {
                validationErrorMessage =
                    "Enter a valid Sri Lankan NIC number."
                return
            }

            validationErrorMessage = nil

            Task {
                await onCompleteProfile(
                    cleanedName,
                    cleanedNIC
                )
            }

            return
        }

        validationErrorMessage = nil

        Task {
            if hasPendingProfile {
                await onRetrySetup()
            } else {
                await onRetryLoad()
            }
        }
    }
}

#Preview {
    AccountRecoveryView(
        initialDisplayName: "Kushad Dissanayake",
        isLoading: false,
        errorMessage: nil,
        requiresName: false,
        requiresNationalIdentityNumber: true,
        hasPendingProfile: false,
        onCompleteProfile: {
            _, _ in
        },
        onRetrySetup: {},
        onRetryLoad: {},
        onSignOut: {}
    )
}
