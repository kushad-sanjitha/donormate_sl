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

    private enum ConnectDonorRecordSource {
        case authentication
        case mainApp
    }

    @Environment(\.scenePhase) private var scenePhase

    @State private var currentFlow: AppFlow = .splash

    @State private var permissionSetupSource:
        PermissionSetupSource = .donorRecordLinked

    @State private var connectDonorRecordSource:
        ConnectDonorRecordSource = .authentication

    @State private var selectedMainTab: MainTab = .home

    @StateObject private var donorRecordsStore =
        DonorRecordsStore()

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
                        connectDonorRecordSource =
                            .authentication

                        currentFlow =
                            .connectDonorRecord
                    }
                )

            case .createAccount:
                CreateAccountView(
                    onBack: {
                        currentFlow = .accountAccess
                    },
                    onCreateAccount: {
                        connectDonorRecordSource =
                            .authentication

                        currentFlow =
                            .connectDonorRecord
                    }
                )

            case .resetPassword:
                ResetPasswordView(
                    onBack: {
                        currentFlow = .signIn
                    },
                    onSendResetLink: {
                        print(
                            "Reset link requested"
                        )
                    },
                    onBackToSignIn: {
                        currentFlow = .signIn
                    }
                )

            case .connectDonorRecord:
                connectDonorRecordScreen

            case .donorRecordLinked:
                donorRecordLinkedScreen

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
                                faceIDProtectionEnabled =
                                    true

                                faceIDUnavailable =
                                    false

                                currentFlow =
                                    .mainApp

                            case .unavailable:
                                faceIDUnavailable =
                                    true

                                currentFlow =
                                    .faceIDUnavailable

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
                        faceIDProtectionEnabled =
                            false

                        faceIDUnavailable =
                            false

                        currentFlow =
                            .mainApp
                    }
                )

            case .faceIDUnavailable:
                FaceIDUnavailableView(
                    onBack: {
                        currentFlow = .faceIDSetup
                    },
                    onContinueWithPassword: {
                        faceIDProtectionEnabled =
                            false

                        currentFlow =
                            .mainApp
                    },
                    onTryAgain: {
                        refreshBiometricAvailability()
                        currentFlow =
                            .faceIDSetup
                    }
                )

            case .mainApp:
                MainTabView(
                    selectedTab:
                        $selectedMainTab,
                    donorRecordsStore:
                        donorRecordsStore,
                    onConnectDonorRecord: {
                        selectedMainTab =
                            .history

                        connectDonorRecordSource =
                            .mainApp

                        currentFlow =
                            .connectDonorRecord
                    }
                )
            }
        }
        .onAppear {
            refreshSetupStatuses()
        }
        .onChange(of: scenePhase) {
            _, newPhase in

            if newPhase == .active {
                refreshSetupStatuses()
            }
        }
    }

    private var connectDonorRecordScreen: some View {

        ConnectDonorRecordView(
            onBack: {
                handleConnectDonorRecordBack()
            },
            onFindRecord: {
                loadDemoDonorData()

                currentFlow =
                    .donorRecordLinked
            },
            onLinkLater: {
                handleLinkLater()
            },
            onNeedHelp: {
                print(
                    "Need help tapped"
                )
            }
        )
    }

    @ViewBuilder
    private var donorRecordLinkedScreen: some View {

        if let profile =
            donorRecordsStore.profile {

            DonorRecordLinkedView(
                name:
                    profile.displayName,
                bloodGroup:
                    profile.bloodGroup,
                donationCount:
                    profile.reportedDonationCount,
                isDemoData: true,
                onContinue: {
                    handleDonorRecordLinkedContinue()
                }
            )

        } else {
            connectDonorRecordScreen
        }
    }

    private func loadDemoDonorData() {

        donorRecordsStore.replaceLinkedData(
            profile: DonorDemoData.profile,
            records: DonorDemoData.records
        )
    }

    private func refreshSetupStatuses() {

        locationPermissionService
            .refreshStatus()

        notificationPermissionService
            .refreshStatus()

        refreshBiometricAvailability()
    }

    private func refreshBiometricAvailability() {

        biometricAuthenticationService
            .refreshAvailability()

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

    private func handleConnectDonorRecordBack() {

        switch connectDonorRecordSource {

        case .authentication:
            currentFlow = .signIn

        case .mainApp:
            selectedMainTab = .history
            currentFlow = .mainApp
        }
    }

    private func handleLinkLater() {

        switch connectDonorRecordSource {

        case .authentication:
            permissionSetupSource =
                .connectDonorRecord

            currentFlow =
                .permissionSetup

        case .mainApp:
            selectedMainTab = .history
            currentFlow = .mainApp
        }
    }

    private func handleDonorRecordLinkedContinue() {

        switch connectDonorRecordSource {

        case .authentication:
            permissionSetupSource =
                .donorRecordLinked

            currentFlow =
                .permissionSetup

        case .mainApp:
            selectedMainTab = .history
            currentFlow = .mainApp
        }
    }

    private func handlePermissionSetupBack() {

        switch permissionSetupSource {

        case .donorRecordLinked:
            currentFlow =
                .donorRecordLinked

        case .connectDonorRecord:
            currentFlow =
                .connectDonorRecord
        }
    }
}

#Preview {
    ContentView()
}
