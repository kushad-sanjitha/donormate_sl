//
//  ContentView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct ContentView: View {

    private enum AppFlow {
            case splash
            case onboarding
            case accountAccess
            case signIn
            case createAccount
            case resetPassword
            case connectDonorRecord
            case donorRecordLinked
            case permissionSetup
            case faceIDSetup
            case faceIDUnavailable
            case mainApp
        }

        private enum PermissionSetupSource {
            case donorRecordLinked
            case connectDonorRecord
        }

        @Environment(\.scenePhase) private var scenePhase

        @State private var currentFlow: AppFlow = .splash

        @State private var permissionSetupSource:
            PermissionSetupSource = .donorRecordLinked

        @StateObject private var locationPermissionService =
            LocationPermissionService()

        @StateObject private var notificationPermissionService =
            NotificationPermissionService()

        @StateObject private var biometricAuthenticationService =
            BiometricAuthenticationService()

        @AppStorage("faceIDProtectionEnabled")
        private var faceIDProtectionEnabled = false

        @State private var faceIDUnavailable = false

        private var faceIDStatus: FaceIDSetupStatus {

            if faceIDUnavailable {
                return .unavailable
            }

            if faceIDProtectionEnabled {
                return .enabled
            }

            return .optional
        }

        var body: some View {
            Group {
                switch currentFlow {

                case .splash:
                    SplashView {
                        currentFlow = .onboarding
                    }

                case .onboarding:
                    OnboardingView(
                        onSkip: {
                            currentFlow = .accountAccess
                        },
                        onFinished: {
                            currentFlow = .accountAccess
                        }
                    )

                case .accountAccess:
                    AccountAccessView(
                        onSignIn: {
                            currentFlow = .signIn
                        },
                        onCreateAccount: {
                            currentFlow = .createAccount
                        }
                    )

                case .signIn:
                    SignInView(
                        onBack: {
                            currentFlow = .accountAccess
                        },
                        onForgotPassword: {
                            currentFlow = .resetPassword
                        },
                        onCreateAccount: {
                            currentFlow = .createAccount
                        },
                        onSignIn: {
                            currentFlow = .connectDonorRecord
                        }
                    )

                case .createAccount:
                    CreateAccountView(
                        onBack: {
                            currentFlow = .accountAccess
                        },
                        onCreateAccount: {
                            currentFlow = .connectDonorRecord
                        }
                    )

                case .resetPassword:
                    ResetPasswordView(
                        onBack: {
                            currentFlow = .signIn
                        },
                        onSendResetLink: {
                            print("Reset link requested")
                        },
                        onBackToSignIn: {
                            currentFlow = .signIn
                        }
                    )

                case .connectDonorRecord:
                    ConnectDonorRecordView(
                        onBack: {
                            currentFlow = .signIn
                        },
                        onFindRecord: {
                            currentFlow = .donorRecordLinked
                        },
                        onLinkLater: {
                            permissionSetupSource = .connectDonorRecord
                            currentFlow = .permissionSetup
                        },
                        onNeedHelp: {
                            print("Need help tapped")
                        }
                    )

                case .donorRecordLinked:
                    DonorRecordLinkedView(
                        name: "Sample Donor",
                        bloodGroup: "A+",
                        donationCount: 6,
                        onContinue: {
                            permissionSetupSource = .donorRecordLinked
                            currentFlow = .permissionSetup
                        }
                    )

                case .permissionSetup:
                    PermissionSetupView(
                        locationStatus:
                            locationPermissionService.status,
                        notificationStatus:
                            notificationPermissionService.status,
                        faceIDStatus:
                            faceIDStatus,
                        onBack: {
                            handlePermissionSetupBack()
                        },
                        onAllowLocation: {
                            locationPermissionService
                                .requestWhenInUsePermission()
                        },
                        onAllowNotifications: {
                            notificationPermissionService
                                .requestPermission()
                        },
                        onContinue: {
                            refreshBiometricAvailability()
                            currentFlow = .faceIDSetup
                        }
                    )

                case .faceIDSetup:
                    FaceIDSetupView(
                        onBack: {
                            currentFlow = .permissionSetup
                        },
                        onEnableFaceID: {
                            Task {
                                let result =
                                    await biometricAuthenticationService
                                        .authenticateWithFaceID()

                                switch result {

                                case .authenticationSucceeded:
                                    faceIDProtectionEnabled = true
                                    faceIDUnavailable = false
                                    currentFlow = .mainApp

                                case .unavailable:
                                    faceIDUnavailable = true
                                    currentFlow = .faceIDUnavailable

                                case .authenticationFailed:
                                    print(
                                        "Face ID authentication failed"
                                    )

                                case .available:
                                    break
                                }
                            }
                        },
                        onNotNow: {
                            faceIDProtectionEnabled = false
                            faceIDUnavailable = false
                            currentFlow = .mainApp
                        }
                    )

                case .faceIDUnavailable:
                    FaceIDUnavailableView(
                        onBack: {
                            currentFlow = .faceIDSetup
                        },
                        onContinueWithPassword: {
                            faceIDProtectionEnabled = false
                            currentFlow = .mainApp
                        },
                        onTryAgain: {
                            refreshBiometricAvailability()
                            currentFlow = .faceIDSetup
                        }
                    )

                case .mainApp:
                    MainTabView()
                }
            }
            .onAppear {
                refreshSetupStatuses()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    refreshSetupStatuses()
                }
            }
        }

        private func refreshSetupStatuses() {
            locationPermissionService.refreshStatus()
            notificationPermissionService.refreshStatus()
            refreshBiometricAvailability()
        }

        private func refreshBiometricAvailability() {
            biometricAuthenticationService.refreshAvailability()

            switch biometricAuthenticationService.state {

            case .available:
                faceIDUnavailable = false

            case .unavailable:
                faceIDUnavailable = true

            case .authenticationSucceeded:
                faceIDUnavailable = false

            case .authenticationFailed:
                break
            }
        }

        private func handlePermissionSetupBack() {
            switch permissionSetupSource {

            case .donorRecordLinked:
                currentFlow = .donorRecordLinked

            case .connectDonorRecord:
                currentFlow = .connectDonorRecord
            }
        }
    }

    #Preview {
        ContentView()
    }
