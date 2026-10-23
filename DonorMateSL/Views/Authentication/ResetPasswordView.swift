//
//  ResetPasswordView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct ResetPasswordView: View {

    @State private var email = ""
    @State private var validationErrorMessage: String?
    @State private var didSendResetLink = false

    let isLoading: Bool
    let authenticationErrorMessage: String?

    var onBack: () -> Void = {}

    var onSendResetLink:
        (String) async -> Bool = { _ in false }

    var onBackToSignIn: () -> Void = {}

    private var displayedErrorMessage: String? {
        validationErrorMessage
        ?? authenticationErrorMessage
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Reset Password",
                isBackDisabled: isLoading,
                onBack: {
                    onBack()
                }
            )

            ScrollView {
                VStack(spacing: 0) {

                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color("DonorRedSoft"),
                                    Color("SurfacePrimary")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(
                            width: 160,
                            height: 110
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    Color("DonorRedBorder"),
                                    lineWidth: 1
                                )
                        }

                    Image(systemName: "envelope.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(Color("DonorRed"))
                        .accessibilityHidden(true)
                }

                Spacer()
                    .frame(height: 24)

                VStack(spacing: 10) {

                    Text("Reset your password")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))
                        .multilineTextAlignment(.center)

                    Text(
                        "Enter the email linked to your DonorMate account. If the request is accepted, Firebase will send password reset instructions."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                }
                .padding(.horizontal, 8)

                Spacer()
                    .frame(height: 24)

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("Email")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color("TextPrimary"))

                    TextField(
                        "name@example.com",
                        text: $email
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextPrimary"))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .submitLabel(.done)
                    .disabled(isLoading)
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(Color("SurfacePrimary"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(
                                Color("BorderPrimary"),
                                lineWidth: 1
                            )
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 13)
                    )
                    .onSubmit {
                        submitResetRequest()
                    }
                    .onChange(of: email) {
                        _, _ in

                        validationErrorMessage = nil
                        didSendResetLink = false
                    }
                }

                if let displayedErrorMessage {
                    Text(displayedErrorMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(Color("DonorRed"))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .padding(.top, 12)
                }

                if didSendResetLink {
                    Text(
                        "If this email can receive a reset request, password reset instructions have been sent."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                    .padding(.top, 12)
                }

                Spacer()
                    .frame(height: 14)

                Button {
                    submitResetRequest()
                } label: {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Send Reset Link")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 48
                    )
                    .background(Color("DonorRed"))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 14)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isLoading)

                Spacer()
                    .frame(height: 10)

                Button {
                    onBackToSignIn()
                } label: {
                    Text("Back to Sign In")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 48
                        )
                        .background(Color("SurfacePrimary"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    Color("BorderPrimary"),
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
                    .frame(height: 26)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        }
        .background(Color("BackgroundPrimary"))
    }

    private func submitResetRequest() {

        guard !isLoading else {
            return
        }

        let cleanedEmail =
            email.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedEmail.isEmpty else {
            validationErrorMessage =
                "Enter your email address."
            return
        }

        validationErrorMessage = nil
        didSendResetLink = false

        Task {
            didSendResetLink =
                await onSendResetLink(
                    cleanedEmail
                )
        }
    }
}

#Preview {
    ResetPasswordView(
        isLoading: false,
        authenticationErrorMessage: nil,
        onBack: {
            print("Back tapped")
        },
        onSendResetLink: {
            email in

            print("Reset link requested for \(email)")
            return true
        },
        onBackToSignIn: {
            print("Back to Sign In tapped")
        }
    )
}
