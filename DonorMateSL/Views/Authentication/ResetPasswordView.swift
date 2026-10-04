//
//  ResetPasswordView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var email = ""

        var onBack: () -> Void = {}
        var onSendResetLink: () -> Void = {}
        var onBackToSignIn: () -> Void = {}

        var body: some View {
            VStack(spacing: 0) {

                HStack {

                    Button {
                        onBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 38, height: 38)
                            .background(Color("SurfacePrimary"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color("BorderPrimary"),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")

                    Spacer()

                    Text("Reset Password")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }

                Spacer()
                    .frame(height: 42)

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
                        "Enter the email linked to your DonorMate account. We will send password reset instructions."
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
                }

                Spacer()
                    .frame(height: 14)

                Button {
                    onSendResetLink()
                } label: {
                    Text("Send Reset Link")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
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

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(Color("BackgroundPrimary"))
        }
    }

    #Preview {
        ResetPasswordView(
            onBack: {
                print("Back tapped")
            },
            onSendResetLink: {
                print("Reset link requested")
            },
            onBackToSignIn: {
                print("Back to Sign In tapped")
            }
        )
    }
