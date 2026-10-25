//
//  PrivacyFaceIDView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import SwiftUI

struct PrivacyFaceIDView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("faceIDProtectionEnabled") private var faceIDProtectionEnabled = false

    @StateObject private var biometricAuthenticationService = BiometricAuthenticationService()
    @State private var isAuthenticating = false
    @State private var showingResultAlert = false
    @State private var resultTitle = ""
    @State private var resultMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Privacy & Face ID",
                onBack: { dismiss() }
            )

            ScreenScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 42, height: 42)
                            .background(Color("NeutralSoft"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Face ID")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color("TextPrimary"))

                            Text("Quick access after account sign-in")
                                .font(.system(size: 12))
                                .foregroundStyle(Color("TextSecondary"))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 4)

                        Toggle("Face ID", isOn: Binding(
                            get: { faceIDProtectionEnabled },
                            set: { shouldEnable in
                                if shouldEnable {
                                    authenticate(enableProtection: true)
                                } else {
                                    faceIDProtectionEnabled = false
                                }
                            }
                        ))
                        .labelsHidden()
                        .tint(Color("DonorRed"))
                        .disabled(isAuthenticating)
                        .accessibilityLabel("Enable Face ID protection")
                    }
                    .padding(14)
                    .background(Color("SurfacePrimary"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color("BorderPrimary"), lineWidth: 1)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    VStack(spacing: 10) {
                        privacyPoint(
                            title: "Biometric data stays with iOS",
                            detail: "DonorMate receives only the authentication result."
                        )

                        privacyPoint(
                            title: "Donation history is view only",
                            detail: "Donors cannot edit blood-bank-recorded donation entries."
                        )

                        privacyPoint(
                            title: "Location is permission based",
                            detail: "Nearby and geofence features work only when allowed."
                        )
                    }

                    Button {
                        authenticate(enableProtection: false)
                    } label: {
                        HStack(spacing: 8) {
                            if isAuthenticating {
                                ProgressView()
                                    .tint(Color("TextPrimary"))
                            }

                            Text("Test Face ID")
                                .font(.system(size: 15, weight: .bold))
                        }
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
                    .disabled(isAuthenticating)
                    .padding(.top, 4)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .alert(resultTitle, isPresented: $showingResultAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(resultMessage)
        }
    }

    private func privacyPoint(title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color("SuccessGreen"))
                .frame(width: 22, height: 22)
                .background(Color("SuccessGreenSoft"))
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))

                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color("SurfacePrimary"))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("BorderPrimary"), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func authenticate(enableProtection: Bool) {
        guard !isAuthenticating else { return }

        isAuthenticating = true

        Task {
            let result = await biometricAuthenticationService.authenticateWithFaceID()
            isAuthenticating = false

            switch result {
            case .authenticationSucceeded:
                if enableProtection {
                    faceIDProtectionEnabled = true
                    presentResult(
                        title: "Face ID enabled",
                        message: "Face ID will be requested when DonorMate restores your signed-in session after a fresh launch."
                    )
                } else {
                    presentResult(
                        title: "Face ID matched",
                        message: "The authentication test succeeded. Your Face ID preference has not changed."
                    )
                }

            case .unavailable:
                presentResult(
                    title: "Face ID unavailable",
                    message: "Face ID is not available or not enrolled on this device. Your setting has not changed."
                )

            case .authenticationFailed:
                presentResult(
                    title: "Face ID did not complete",
                    message: "Authentication failed or was cancelled. Your setting has not changed."
                )

            case .available:
                break
            }
        }
    }

    private func presentResult(title: String, message: String) {
        resultTitle = title
        resultMessage = message
        showingResultAlert = true
    }
}

#Preview("Screen 36 - Privacy & Face ID") {
    NavigationStack {
        PrivacyFaceIDView()
    }
}
