//
//  StaffSignInView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import SwiftUI

struct StaffSignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var validationErrorMessage: String?
    @State private var didRequestPasswordReset = false

    let isLoading: Bool
    let errorMessage: String?
    let onSignIn: (String, String) async -> Void
    let onForgotPassword: (String) async -> Bool
    let onEdit: () -> Void
    let onBack: () -> Void

    private var displayedError: String? {
        validationErrorMessage ?? errorMessage
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Staff Sign In",
                isBackDisabled: isLoading,
                onBack: onBack
            )

            ScreenScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("STAFF ACCESS")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color("DonorRed"))

                    Text("Sign in to DonorMate.")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))
                        .padding(.top, 10)

                    Text("Use your staff account to review donor records.")
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                        .lineSpacing(3)
                        .padding(.top, 10)

                    VStack(spacing: 16) {
                        StaffFormField(title: "Email") {
                            TextField("name@example.com", text: $email)
                                .textContentType(.username)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.next)
                                .disabled(isLoading)
                                .onChange(of: email) { _, _ in inputChanged() }
                        }

                        StaffFormField(title: "Password") {
                            HStack(spacing: 10) {
                                Group {
                                    if isPasswordVisible {
                                        TextField("Password", text: $password)
                                    } else {
                                        SecureField("Password", text: $password)
                                    }
                                }
                                .textContentType(.password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .submitLabel(.go)
                                .disabled(isLoading)
                                .onSubmit(submitSignIn)
                                .onChange(of: password) { _, _ in inputChanged() }

                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color("TextSecondary"))
                                        .frame(width: 32, height: 32)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                                .disabled(isLoading)
                                .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                            }
                        }

                        HStack {
                            Spacer()
                            Button("Forgot password?", action: requestPasswordReset)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(Color("DonorRed"))
                                .padding(.vertical, 8)
                                .disabled(isLoading)
                        }

                        if let displayedError {
                            Text(displayedError)
                                .font(.system(size: 12))
                                .foregroundStyle(Color("DonorRed"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel("Sign-in error: \(displayedError)")
                        }

                        if didRequestPasswordReset {
                            StaffNotice(message: "If your email is registered, password reset instructions have been sent.")
                        }

                        Button(action: submitSignIn) {
                            Group {
                                if isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("DonorRed"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading)
                    }
                    .padding(.top, 24)

                    StaffNotice(message: "Only approved blood-bank staff can access donor verification.")
                        .padding(.top, 22)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color("BackgroundPrimary"))
    }

    private func inputChanged() {
        validationErrorMessage = nil
        didRequestPasswordReset = false
        onEdit()
    }

    private func submitSignIn() {
        guard !isLoading else { return }
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedEmail.isEmpty, !password.isEmpty else {
            validationErrorMessage = "Enter your email and password."
            return
        }
        validationErrorMessage = nil
        Task { await onSignIn(cleanedEmail, password) }
    }

    private func requestPasswordReset() {
        guard !isLoading else { return }
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedEmail.isEmpty else {
            validationErrorMessage = "Enter your staff email first."
            return
        }
        validationErrorMessage = nil
        Task {
            didRequestPasswordReset = await onForgotPassword(cleanedEmail)
        }
    }
}
