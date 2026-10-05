//
//  PermissionSetupView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import SwiftUI

struct PermissionSetupView: View {
    let locationStatus: LocationPermissionStatus

        var onBack: () -> Void = {}
        var onAllowLocation: () -> Void = {}
        var onAllowNotifications: () -> Void = {}
        var onContinue: () -> Void = {}

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

                        Text("Set Up DonorMate")
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

                        Text("PERMISSIONS")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(Color("DonorRed"))

                        Text("Enable the features that make DonorMate useful.")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Color("TextPrimary"))
                            .padding(.top, 10)

                        Text(
                            "You can change these permissions later in Settings."
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

                    VStack(spacing: 12) {

                        permissionCard(
                            icon: "location.fill",
                            iconForeground: Color("InfoBlue"),
                            iconBackground: Color("InfoBlueSoft"),
                            title: "Location",
                            description: "Nearby discovery, distance and location-aware alerts.",
                            actionTitle: locationActionTitle,
                            actionForeground: locationActionForeground,
                            actionBackground: locationActionBackground,
                            actionEnabled: locationStatus == .notDetermined,
                            action: onAllowLocation
                        )

                        permissionCard(
                            icon: "bell.fill",
                            iconForeground: Color("DonorRed"),
                            iconBackground: Color("DonorRedSoft"),
                            title: "Notifications",
                            description: "Donation reminders, campaign reminders and urgent needs.",
                            actionTitle: "Allow",
                            actionForeground: Color("DonorRed"),
                            actionBackground: Color("DonorRedSoft"),
                            actionEnabled: true,
                            action: onAllowNotifications
                        )

                        permissionCard(
                            icon: "faceid",
                            iconForeground: Color("TextPrimary"),
                            iconBackground: Color("NeutralSoft"),
                            title: "Face ID",
                            description: "Protect access to personal donor information.",
                            actionTitle: "Optional",
                            actionForeground: Color("TextSecondary"),
                            actionBackground: Color("NeutralSoft"),
                            actionEnabled: false,
                            action: nil
                        )
                    }

                    Spacer()
                        .frame(height: 16)

                    HStack(
                        alignment: .top,
                        spacing: 10
                    ) {

                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    Color("InfoBlue")
                                        .opacity(0.10)
                                )
                                .frame(
                                    width: 36,
                                    height: 36
                                )

                            Image(systemName: "info.circle.fill")
                                .font(
                                    .system(
                                        size: 18,
                                        weight: .semibold
                                    )
                                )
                                .foregroundStyle(Color("InfoBlue"))
                        }
                        .accessibilityHidden(true)

                        Text(
                            "Privacy: permission-dependent features still show a clear fallback when access is declined."
                        )
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextPrimary"))
                        .lineSpacing(2)

                        Spacer(minLength: 0)
                    }
                    .padding(14)
                    .background(Color("InfoBlueSoft"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                Color("InfoBlue").opacity(0.18),
                                lineWidth: 1
                            )
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

                    Spacer()
                        .frame(height: 20)

                    Button {
                        onContinue()
                    } label: {
                        Text("Continue")
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

        private var locationActionTitle: String {

            switch locationStatus {

            case .notDetermined:
                return "Allow"

            case .authorized:
                return "Allowed ✓"

            case .denied:
                return "Denied"

            case .restricted:
                return "Restricted"
            }
        }

        private var locationActionForeground: Color {

            switch locationStatus {

            case .authorized:
                return Color("SuccessGreen")

            case .denied,
                 .restricted:
                return Color("TextSecondary")

            case .notDetermined:
                return Color("DonorRed")
            }
        }

        private var locationActionBackground: Color {

            switch locationStatus {

            case .authorized:
                return Color("SuccessGreenSoft")

            case .denied,
                 .restricted:
                return Color("NeutralSoft")

            case .notDetermined:
                return Color("DonorRedSoft")
            }
        }


        private func permissionCard(
            icon: String,
            iconForeground: Color,
            iconBackground: Color,
            title: String,
            description: String,
            actionTitle: String,
            actionForeground: Color,
            actionBackground: Color,
            actionEnabled: Bool,
            action: (() -> Void)?
        ) -> some View {

            HStack(
                alignment: .center,
                spacing: 12
            ) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackground)
                        .frame(
                            width: 44,
                            height: 44
                        )

                    Image(systemName: icon)
                        .font(
                            .system(
                                size: 18,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(iconForeground)
                }
                .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Text(description)
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextSecondary"))
                        .lineSpacing(2)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                if let action {

                    Button {
                        if actionEnabled {
                            action()
                        }
                    } label: {
                        Text(actionTitle)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(actionForeground)
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                            .background(actionBackground)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!actionEnabled)

                } else {

                    Text(actionTitle)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(actionForeground)
                        .padding(.horizontal, 10)
                        .frame(height: 34)
                        .background(actionBackground)
                        .clipShape(Capsule())
                }
            }
            .padding(14)
            .background(Color("SurfacePrimary"))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color("BorderPrimary"),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
    }

    #Preview {
        PermissionSetupView(
            locationStatus: .notDetermined,
            onBack: {
                print("Back tapped")
            },
            onAllowLocation: {
                print("Location requested")
            },
            onAllowNotifications: {
                print("Notification permission requested")
            },
            onContinue: {
                print("Continue tapped")
            }
        )
    }
