//
//  CreateAccountView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct CreateAccountView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    var onBack: () -> Void = {}
    var onCreateAccount: () -> Void = {}

    var body: some View {
        ScrollView {
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

                    Text("Create Account")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }

                Spacer()
                    .frame(height: 18)

                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    Text("NEW ACCOUNT")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color("DonorRed"))

                    Text("Create your DonorMate account.")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))
                        .padding(.top, 10)

                    Text(
                        "This account gives you secure access to the donor companion."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .lineSpacing(3)
                    .padding(.top, 10)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
                    .frame(height: 24)

                VStack(spacing: 16) {

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        fieldLabel("Full name")

                        TextField(
                            "Your full name",
                            text: $fullName
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextPrimary"))
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
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

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        fieldLabel("Email")

                        TextField(
                            "name@example.com",
                            text: $email
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextPrimary"))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .submitLabel(.next)
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

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        fieldLabel("Password")

                        secureInput(
                            placeholder: "Password",
                            text: $password,
                            isVisible: $isPasswordVisible,
                            accessibilityLabel: "password",
                            submitLabel: .next
                        )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        fieldLabel("Confirm password")

                        secureInput(
                            placeholder: "Confirm password",
                            text: $confirmPassword,
                            isVisible: $isConfirmPasswordVisible,
                            accessibilityLabel: "confirm password",
                            submitLabel: .done
                        )
                    }
                }

                Spacer()
                    .frame(height: 18)

                Text(
                    "By continuing, you agree to use DonorMate only for your own donor-linked information."
                )
                .font(.system(size: 12))
                .foregroundStyle(Color("TextSecondary"))
                .lineSpacing(2)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
                    .frame(height: 18)

                Button {
                    onCreateAccount()
                } label: {
                    Text("Create Account")
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
                    .frame(height: 26)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        .background(Color("BackgroundPrimary"))
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color("TextPrimary"))
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
    }

    private func secureInput(
        placeholder: String,
        text: Binding<String>,
        isVisible: Binding<Bool>,
        accessibilityLabel: String,
        submitLabel: SubmitLabel
    ) -> some View {

        HStack(spacing: 10) {

            Group {
                if isVisible.wrappedValue {
                    TextField(
                        placeholder,
                        text: text
                    )
                } else {
                    SecureField(
                        placeholder,
                        text: text
                    )
                }
            }
            .font(.system(size: 14))
            .foregroundStyle(Color("TextPrimary"))
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(submitLabel)

            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(
                    systemName:
                        isVisible.wrappedValue
                        ? "eye.slash"
                        : "eye"
                )
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color("TextSecondary"))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                isVisible.wrappedValue
                ? "Hide \(accessibilityLabel)"
                : "Show \(accessibilityLabel)"
            )
        }
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
}

#Preview {
    CreateAccountView(
        onBack: {
            print("Back tapped")
        },
        onCreateAccount: {
            print("Create Account submitted")
        }
    )
}
