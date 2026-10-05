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
        }

        private enum PermissionSetupSource {
            case donorRecordLinked
            case connectDonorRecord
        }

        @State private var currentFlow: AppFlow = .splash
        @State private var permissionSetupSource: PermissionSetupSource = .donorRecordLinked

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
                        onBack: {
                            handlePermissionSetupBack()
                        },
                        onAllowLocation: {
                            print("Location permission requested")
                        },
                        onAllowNotifications: {
                            print("Notification permission requested")
                        },
                        onContinue: {
                            currentFlow = .faceIDSetup
                        }
                    )

                case .faceIDSetup:
                    FaceIDSetupView(
                        onBack: {
                            currentFlow = .permissionSetup
                        },
                        onEnableFaceID: {
                            currentFlow = .faceIDUnavailable
                        },
                        onNotNow: {
                            print("Face ID skipped")
                        }
                    )

                case .faceIDUnavailable:
                    FaceIDUnavailableView(
                        onBack: {
                            currentFlow = .faceIDSetup
                        },
                        onContinueWithPassword: {
                            print("Continue with password tapped")
                        },
                        onTryAgain: {
                            currentFlow = .faceIDSetup
                        }
                    )
                }
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
