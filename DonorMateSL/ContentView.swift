//
//  ContentView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct ContentView: View {

    private enum AppFlow: Equatable {
        case splash
        case onboarding
        case accountAccess
        case signIn
        case createAccount
        case resetPassword
        case accountRecovery
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

    @Environment(\.scenePhase)
    private var scenePhase

    @State private var currentFlow:
        AppFlow = .splash

    @State private var permissionSetupSource:
        PermissionSetupSource =
            .donorRecordLinked

    @State private var connectDonorRecordSource:
        ConnectDonorRecordSource =
            .authentication

    @State private var selectedMainTab:
        MainTab = .home

    @State private var waitingForSessionResolution =
        false

    @StateObject private var donorRecordsStore =
        DonorRecordsStore()

    @StateObject private var accountSessionStore =
        AccountSessionStore()

    @StateObject private var locationPermissionService =
        LocationPermissionService()

    @StateObject private var notificationPermissionService =
        NotificationPermissionService()

    @StateObject private var biometricAuthenticationService =
        BiometricAuthenticationService()

    @AppStorage("faceIDProtectionEnabled")
    private var faceIDProtectionEnabled = false

    @State private var faceIDUnavailable = false

    private var faceIDStatus:
        FaceIDSetupStatus {

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
                    handleSplashContinue()
                }

            case .onboarding:
                OnboardingView(
                    onSkip: {
                        currentFlow =
                            .accountAccess
                    },
                    onFinished: {
                        currentFlow =
                            .accountAccess
                    }
                )

            case .accountAccess:
                AccountAccessView(
                    onSignIn: {
                        accountSessionStore
                            .clearError()

                        currentFlow =
                            .signIn
                    },
                    onCreateAccount: {
                        accountSessionStore
                            .clearError()

                        currentFlow =
                            .createAccount
                    }
                )

            case .signIn:
                SignInView(
                    isLoading:
                        accountSessionStore
                            .isLoading,
                    authenticationErrorMessage:
                        accountSessionStore
                            .errorMessage,
                    onBack: {
                        accountSessionStore
                            .clearError()

                        currentFlow =
                            .accountAccess
                    },
                    onForgotPassword: {
                        accountSessionStore
                            .clearError()

                        currentFlow =
                            .resetPassword
                    },
                    onCreateAccount: {
                        accountSessionStore
                            .clearError()

                        currentFlow =
                            .createAccount
                    },
                    onSignIn: {
                        email,
                        password in

                        let succeeded =
                            await accountSessionStore
                                .signIn(
                                    email:
                                        email,
                                    password:
                                        password
                                )

                        guard succeeded else {

                            if accountSessionStore
                                .needsProfileSetup {

                                currentFlow =
                                    .accountRecovery
                            }

                            return
                        }

                        guard hasValidAccountProfile else {
                            currentFlow =
                                .accountRecovery

                            return
                        }

                        connectDonorRecordSource =
                            .authentication

                        currentFlow =
                            .connectDonorRecord
                    }
                )

            case .createAccount:
                CreateAccountView(
                    isLoading:
                        accountSessionStore
                            .isLoading,
                    authenticationErrorMessage:
                        accountSessionStore
                            .errorMessage,
                    onBack: {
                        accountSessionStore
                            .clearError()

                        currentFlow =
                            .accountAccess
                    },
                    onCreateAccount: {
                        fullName,
                        email,
                        password in

                        let succeeded =
                            await accountSessionStore
                                .createAccount(
                                    displayName:
                                        fullName,
                                    email:
                                        email,
                                    password:
                                        password
                                )

                        guard succeeded else {

                            if accountSessionStore
                                .needsProfileSetup {

                                currentFlow =
                                    .accountRecovery
                            }

                            return
                        }

                        guard hasValidAccountProfile else {
                            currentFlow =
                                .accountRecovery

                            return
                        }

                        connectDonorRecordSource =
                            .authentication

                        currentFlow =
                            .connectDonorRecord
                    }
                )

            case .resetPassword:
                ResetPasswordView(
                    onBack: {
                        currentFlow =
                            .signIn
                    },
                    onSendResetLink: {
                        print(
                            "Reset link requested"
                        )
                    },
                    onBackToSignIn: {
                        currentFlow =
                            .signIn
                    }
                )

            case .accountRecovery:
                AccountRecoveryView(
                    isLoading:
                        accountSessionStore
                            .isLoading,
                    errorMessage:
                        accountSessionStore
                            .errorMessage,
                    requiresName:
                        accountSessionStore
                            .requiresProfileName,
                    hasPendingProfile:
                        accountSessionStore
                            .pendingProfile != nil,
                    onCompleteName: {
                        displayName in

                        let succeeded =
                            await accountSessionStore
                                .completeMissingProfile(
                                    displayName:
                                        displayName
                                )

                        guard succeeded,
                              hasValidAccountProfile else {
                            return
                        }

                        connectDonorRecordSource =
                            .authentication

                        currentFlow =
                            .connectDonorRecord
                    },
                    onRetrySetup: {

                        let succeeded =
                            await accountSessionStore
                                .retryProfileSetup()

                        guard succeeded,
                              hasValidAccountProfile else {
                            return
                        }

                        connectDonorRecordSource =
                            .authentication

                        currentFlow =
                            .connectDonorRecord
                    },
                    onRetryLoad: {

                        let succeeded =
                            await accountSessionStore
                                .retryProfileLoad()

                        guard succeeded,
                              hasValidAccountProfile else {
                            return
                        }

                        connectDonorRecordSource =
                            .authentication

                        currentFlow =
                            .connectDonorRecord
                    },
                    onSignOut: {
                        accountSessionStore
                            .signOut()

                        donorRecordsStore
                            .unlink()

                        selectedMainTab =
                            .home

                        currentFlow =
                            .accountAccess
                    }
                )

            case .connectDonorRecord:
                connectDonorRecordScreen

            case .donorRecordLinked:
                donorRecordLinkedScreen

            case .permissionSetup:
                PermissionSetupView(
                    locationStatus:
                        locationPermissionService
                            .status,
                    notificationStatus:
                        notificationPermissionService
                            .status,
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

                        currentFlow =
                            .faceIDSetup
                    }
                )

            case .faceIDSetup:
                FaceIDSetupView(
                    onBack: {
                        currentFlow =
                            .permissionSetup
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
                        currentFlow =
                            .faceIDSetup
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
            _,
            newPhase in

            if newPhase == .active {
                refreshSetupStatuses()
            }
        }
        .onChange(
            of:
                accountSessionStore
                    .authenticatedUserID
        ) {
            previousUserID,
            newUserID in

            handleAuthenticatedUserChange(
                previousUserID:
                    previousUserID,
                newUserID:
                    newUserID
            )
        }
        .onChange(
            of:
                accountSessionStore
                    .isAuthStateResolved
        ) {
            _,
            isResolved in

            guard isResolved else {
                return
            }

            if waitingForSessionResolution {
                routeAfterSplash()
            }

            enforceProtectedFlowAccess()
        }
        .onChange(
            of:
                accountSessionStore
                    .profile?.uid
        ) {
            _,
            newProfileUserID in

            if waitingForSessionResolution,
               newProfileUserID != nil {

                routeAfterSplash()
            }

            if currentFlow ==
                .accountRecovery,
               hasValidAccountProfile {

                connectDonorRecordSource =
                    .authentication

                currentFlow =
                    .connectDonorRecord
            }

            enforceProtectedFlowAccess()
        }
        .onChange(
            of:
                accountSessionStore
                    .needsProfileSetup
        ) {
            _,
            needsSetup in

            guard needsSetup,
                  accountSessionStore
                    .authenticatedUserID != nil else {

                return
            }

            switch currentFlow {

            case .signIn,
                 .createAccount,
                 .accountRecovery:

                currentFlow =
                    .accountRecovery

            default:
                enforceProtectedFlowAccess()
            }
        }
        .onChange(
            of:
                accountSessionStore
                    .isLoading
        ) {
            _,
            isLoading in

            guard !isLoading else {
                return
            }

            if waitingForSessionResolution {
                routeAfterSplash()
            }

            enforceProtectedFlowAccess()
        }
    }

    private var hasValidAccountProfile:
        Bool {

        guard let userID =
                accountSessionStore
                    .authenticatedUserID,
              let profile =
                accountSessionStore
                    .profile else {

            return false
        }

        return profile.uid == userID
    }

    private var connectDonorRecordScreen:
        some View {

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
    private var donorRecordLinkedScreen:
        some View {

        if let profile =
            donorRecordsStore.profile {

            DonorRecordLinkedView(
                name:
                    profile.displayName,
                bloodGroup:
                    profile.bloodGroup,
                donationCount:
                    profile
                        .reportedDonationCount,
                isDemoData: true,
                onContinue: {
                    handleDonorRecordLinkedContinue()
                }
            )

        } else {
            connectDonorRecordScreen
        }
    }

    private func handleSplashContinue() {

        if !accountSessionStore
            .isAuthStateResolved
            || accountSessionStore
                .isLoading {

            waitingForSessionResolution =
                true

            return
        }

        routeAfterSplash()
    }

    private func routeAfterSplash() {

        guard accountSessionStore
            .isAuthStateResolved else {

            waitingForSessionResolution =
                true

            return
        }

        if accountSessionStore
            .isLoading {

            waitingForSessionResolution =
                true

            return
        }

        waitingForSessionResolution =
            false

        guard accountSessionStore
            .authenticatedUserID != nil else {

            currentFlow =
                .onboarding

            return
        }

        if hasValidAccountProfile {

            connectDonorRecordSource =
                .authentication

            currentFlow =
                .connectDonorRecord

            return
        }

        currentFlow =
            .accountRecovery
    }

    private func handleAuthenticatedUserChange(
        previousUserID: String?,
        newUserID: String?
    ) {

        if previousUserID != newUserID {

            donorRecordsStore
                .unlink()
        }

        guard accountSessionStore
            .isAuthStateResolved else {

            return
        }

        guard newUserID != nil else {

            if requiresAuthenticatedAccount(
                currentFlow
            )
            || currentFlow ==
                .accountRecovery {

                selectedMainTab =
                    .home

                connectDonorRecordSource =
                    .authentication

                currentFlow =
                    .accountAccess
            }

            return
        }

        if waitingForSessionResolution {
            routeAfterSplash()
        }

        enforceProtectedFlowAccess()
    }

    private func enforceProtectedFlowAccess() {

        guard requiresAuthenticatedAccount(
            currentFlow
        ) else {
            return
        }

        guard accountSessionStore
            .isAuthStateResolved else {
            return
        }

        guard accountSessionStore
            .authenticatedUserID != nil else {

            donorRecordsStore
                .unlink()

            selectedMainTab =
                .home

            currentFlow =
                .accountAccess

            return
        }

        if hasValidAccountProfile {
            return
        }

        if accountSessionStore
            .isLoading {

            return
        }

        donorRecordsStore
            .unlink()

        currentFlow =
            .accountRecovery
    }

    private func loadDemoDonorData() {

        guard hasValidAccountProfile else {
            currentFlow =
                .accountRecovery

            return
        }

        donorRecordsStore
            .replaceLinkedData(
                profile:
                    DonorDemoData.profile,
                records:
                    DonorDemoData.records
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

        switch biometricAuthenticationService
            .state {

        case .available:
            faceIDUnavailable =
                false

        case .unavailable:
            faceIDUnavailable =
                true

        case .authenticationSucceeded:
            faceIDUnavailable =
                false

        case .authenticationFailed:
            break
        }
    }

    private func handleConnectDonorRecordBack() {

        switch connectDonorRecordSource {

        case .authentication:
            currentFlow =
                .signIn

        case .mainApp:
            selectedMainTab =
                .history

            currentFlow =
                .mainApp
        }
    }

    private func handleLinkLater() {

        guard hasValidAccountProfile else {

            currentFlow =
                .accountRecovery

            return
        }

        donorRecordsStore
            .unlink()

        switch connectDonorRecordSource {

        case .authentication:
            permissionSetupSource =
                .connectDonorRecord

            currentFlow =
                .permissionSetup

        case .mainApp:
            selectedMainTab =
                .history

            currentFlow =
                .mainApp
        }
    }

    private func handleDonorRecordLinkedContinue() {

        guard hasValidAccountProfile else {

            currentFlow =
                .accountRecovery

            return
        }

        switch connectDonorRecordSource {

        case .authentication:
            permissionSetupSource =
                .donorRecordLinked

            currentFlow =
                .permissionSetup

        case .mainApp:
            selectedMainTab =
                .history

            currentFlow =
                .mainApp
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

    private func requiresAuthenticatedAccount(
        _ flow: AppFlow
    ) -> Bool {

        switch flow {

        case .connectDonorRecord,
             .donorRecordLinked,
             .permissionSetup,
             .faceIDSetup,
             .faceIDUnavailable,
             .mainApp:

            return true

        case .splash,
             .onboarding,
             .accountAccess,
             .signIn,
             .createAccount,
             .resetPassword,
             .accountRecovery:

            return false
        }
    }
}

private struct AccountRecoveryView:
    View {

    @State private var displayName = ""

    let isLoading: Bool
    let errorMessage: String?
    let requiresName: Bool
    let hasPendingProfile: Bool

    let onCompleteName:
        (String) async -> Void

    let onRetrySetup:
        () async -> Void

    let onRetryLoad:
        () async -> Void

    let onSignOut:
        () -> Void

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

                    Text("Full name")
                        .font(
                            .system(
                                size: 12,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(
                            Color("TextPrimary")
                        )
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

                if let errorMessage {

                    Text(errorMessage)
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
                .disabled(
                    isLoading
                    || (
                        requiresName
                        && displayName
                            .trimmingCharacters(
                                in:
                                    .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                )
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

    private var recoveryDescription:
        String {

        if requiresName {
            return "Your Firebase account is signed in, but your profile needs your name before setup can continue."
        }

        if hasPendingProfile {
            return "Your Firebase account was created, but the profile could not be saved. Retry the profile setup without creating another account."
        }

        return "Your Firebase session is still valid, but your account profile could not be loaded. Check your connection and try again."
    }

    private var primaryButtonTitle:
        String {

        if requiresName {
            return "Complete Profile"
        }

        if hasPendingProfile {
            return "Retry Profile Setup"
        }

        return "Retry"
    }

    private func performPrimaryAction() {

        guard !isLoading else {
            return
        }

        Task {
            if requiresName {

                let cleanedName =
                    displayName
                        .trimmingCharacters(
                            in:
                                .whitespacesAndNewlines
                        )

                await onCompleteName(
                    cleanedName
                )

            } else if hasPendingProfile {

                await onRetrySetup()

            } else {

                await onRetryLoad()
            }
        }
    }
}

#Preview {
    ContentView()
}
