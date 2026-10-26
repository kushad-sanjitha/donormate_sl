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

    @State private var isRestoredSessionUnlocking =
        false

    @State private var showBiometricUnlockFailure =
        false

    @StateObject private var donorRecordsStore = DonorRecordsStore()
    @StateObject private var donationLocationStore = DonationLocationStore()
    @StateObject private var urgentBloodNeedStore = UrgentBloodNeedStore()
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var notificationInboxStore = NotificationInboxStore.shared
    @StateObject private var notificationPreferencesStore = NotificationPreferencesStore.shared

    private let donorRecordProvider = DemoDonorRecordProvider()

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
                                .needsAccountRecovery {

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
                        nationalIdentityNumber,
                        email,
                        password in

                        let succeeded =
                            await accountSessionStore
                                .createAccount(
                                    displayName:
                                        fullName,
                                    nationalIdentityNumber:
                                        nationalIdentityNumber,
                                    email:
                                        email,
                                    password:
                                        password
                                )

                        guard succeeded else {

                            if accountSessionStore
                                .needsAccountRecovery {

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
                            .signIn
                    },
                    onSendResetLink: {
                        email in

                        await accountSessionStore
                            .requestPasswordReset(
                                email: email
                            )
                    },
                    onBackToSignIn: {
                        accountSessionStore
                            .clearError()

                        currentFlow =
                            .signIn
                    }
                )

            case .accountRecovery:
                accountRecoveryScreen

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
                if let accountProfile =
                    validAccountProfile {

                    MainTabView(
                        selectedTab:
                            $selectedMainTab,
                        donorRecordsStore:
                            donorRecordsStore,
                        accountProfile: accountProfile,
                        donationLocationStore: donationLocationStore,
                        urgentBloodNeedStore: urgentBloodNeedStore,
                        savedItemsStore: savedItemsStore,
                        notificationInboxStore: notificationInboxStore,
                        locationPermissionService: locationPermissionService,
                        isAccountLoading:
                            accountSessionStore
                                .isLoading,
                        accountErrorMessage:
                            accountSessionStore
                                .errorMessage,
                        onConnectDonorRecord: {
                            selectedMainTab =
                                .history

                            connectDonorRecordSource =
                                .mainApp

                            currentFlow =
                                .connectDonorRecord
                        },
                        onSignOut: {
                            handleAccountSignOut()
                        }
                    )
                    .environmentObject(notificationPreferencesStore)

                } else {
                    accountRecoveryScreen
                }
            }
        }
        .onAppear {
            refreshSetupStatuses()
            notificationInboxStore.activate(for: accountSessionStore.authenticatedUserID)
            notificationPreferencesStore.activate(for: accountSessionStore.authenticatedUserID)
            Task {
                await savedItemsStore.activate(for: accountSessionStore.authenticatedUserID)
            }
            synchronizeWidgetSnapshot()
        }
        .onReceive(donorRecordsStore.$state) { updatedState in
            guard accountSessionStore.isAuthStateResolved else { return }
            DonorMateWidgetPublisher.synchronize(
                userID: validAccountProfile?.uid,
                donorState: updatedState
            )
        }
        .onReceive(donationLocationStore.$locations) { locations in
            Task {
                await NearbyAlertMonitorService.shared
                    .replaceLocations(locations)
                await NearbyAlertMonitorService.shared
                    .startObservingEvents()
            }
        }
        .onChange(of: scenePhase) {
            _,
            newPhase in

            if newPhase == .active {
                refreshSetupStatuses()
                synchronizeWidgetSnapshot()
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
            notificationInboxStore.activate(for: newUserID)
            notificationPreferencesStore.activate(for: newUserID)
            Task {
                await savedItemsStore.activate(for: newUserID)
            }
            synchronizeWidgetSnapshot()
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

            synchronizeWidgetSnapshot()

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
            synchronizeWidgetSnapshot()
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
        .alert(
            "Face ID could not unlock DonorMate",
            isPresented:
                $showBiometricUnlockFailure
        ) {
            Button("Try Again") {
                requestRestoredSessionUnlock()
            }

            Button("Use Password") {
                usePasswordForRestoredSession()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "Your Firebase session is still protected. Try Face ID again or sign in with your password."
            )
        }
    }

    private func synchronizeWidgetSnapshot() {
        guard accountSessionStore.isAuthStateResolved else { return }
        DonorMateWidgetPublisher.synchronize(
            userID: validAccountProfile?.uid,
            donorState: donorRecordsStore.state
        )
    }

    private var validAccountProfile:
        AccountProfile? {

        guard let userID =
                accountSessionStore
                    .authenticatedUserID,
              let profile =
                accountSessionStore
                    .profile,
              profile.uid == userID,
              profile.hasNationalIdentityNumber else {

            return nil
        }

        return profile
    }

    private var hasValidAccountProfile:
        Bool {

        validAccountProfile != nil
    }

    private var accountRecoveryScreen:
        some View {

        AccountRecoveryView(
            initialDisplayName:
                accountSessionStore
                    .recoveryDisplayName
                ?? accountSessionStore
                    .profile?
                    .displayName,
            isLoading:
                accountSessionStore
                    .isLoading,
            errorMessage:
                accountSessionStore
                    .errorMessage,
            requiresName:
                accountSessionStore
                    .requiresProfileName,
            requiresNationalIdentityNumber:
                accountSessionStore
                    .requiresNationalIdentityNumber,
            hasPendingProfile:
                accountSessionStore
                    .pendingProfile != nil,
            onCompleteProfile: {
                displayName,
                nationalIdentityNumber in

                let succeeded =
                    await accountSessionStore
                        .completeMissingProfile(
                            displayName:
                                displayName,
                            nationalIdentityNumber:
                                nationalIdentityNumber
                        )

                guard succeeded,
                      hasValidAccountProfile else {
                    return
                }

                openAuthenticatedEntryFlow()
            },
            onRetrySetup: {

                let succeeded =
                    await accountSessionStore
                        .retryProfileSetup()

                guard succeeded,
                      hasValidAccountProfile else {
                    return
                }

                openAuthenticatedEntryFlow()
            },
            onRetryLoad: {

                let succeeded =
                    await accountSessionStore
                        .retryProfileLoad()

                guard succeeded,
                      hasValidAccountProfile else {
                    return
                }

                openAuthenticatedEntryFlow()
            },
            onSignOut: {
                handleAccountSignOut()
            }
        )
    }

    private var connectDonorRecordScreen:
        some View {

        ConnectDonorRecordView(
            maskedNationalIdentityNumber:
                validAccountProfile?
                    .maskedNationalIdentityNumber
                ?? "Unavailable",
            onBack: {
                handleConnectDonorRecordBack()
            },
            onFindRecord: {
                donorRecordID in

                guard await loadDonorData(
                    donorRecordID: donorRecordID
                ) else {
                    return false
                }

                currentFlow =
                    .donorRecordLinked

                return true
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
                isDemoData: !donorRecordsStore.isVerified,
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

            if faceIDProtectionEnabled {
                requestRestoredSessionUnlock()
            } else {
                openAuthenticatedEntryFlow()
            }

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

            if previousUserID != nil {
                faceIDProtectionEnabled =
                    false
            }
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

    private func loadDonorData(
        donorRecordID: String
    ) async -> Bool {
        guard let account = validAccountProfile else {
            currentFlow = .accountRecovery
            return false
        }

        do {
            guard let result = try await donorRecordProvider.findRecord(
                account: account,
                donorRecordID: donorRecordID
            ) else {
                return false
            }

            guard validAccountProfile?.uid == account.uid,
                  currentFlow == .connectDonorRecord else {
                return false
            }

            donorRecordsStore.replaceLinkedData(
                profile: result.profile,
                records: result.records,
                isVerified: result.isVerified
            )
            return true
        } catch {
            return false
        }
    }

    private func openAuthenticatedEntryFlow() {

        connectDonorRecordSource =
            .authentication

        currentFlow =
            .connectDonorRecord
    }

    private func requestRestoredSessionUnlock() {

        guard faceIDProtectionEnabled else {
            openAuthenticatedEntryFlow()
            return
        }

        guard hasValidAccountProfile else {
            currentFlow =
                .accountRecovery
            return
        }

        guard !isRestoredSessionUnlocking else {
            return
        }

        isRestoredSessionUnlocking =
            true

        Task {
            let result =
                await biometricAuthenticationService
                    .authenticateWithFaceID()

            isRestoredSessionUnlocking =
                false

            guard hasValidAccountProfile else {
                currentFlow =
                    .accountRecovery
                return
            }

            switch result {

            case .authenticationSucceeded:
                faceIDUnavailable =
                    false

                openAuthenticatedEntryFlow()

            case .unavailable:
                faceIDUnavailable =
                    true

                showBiometricUnlockFailure =
                    true

            case .authenticationFailed:
                showBiometricUnlockFailure =
                    true

            case .available:
                break
            }
        }
    }

    private func usePasswordForRestoredSession() {

        let signedOut =
            accountSessionStore
                .signOut()

        guard signedOut else {
            currentFlow =
                .accountRecovery
            return
        }

        donorRecordsStore
            .unlink()

        faceIDProtectionEnabled =
            false

        selectedMainTab =
            .home

        currentFlow =
            .signIn
    }

    private func handleAccountSignOut() {

        let signedOut =
            accountSessionStore
                .signOut()

        guard signedOut else {
            return
        }

        donorRecordsStore
            .unlink()

        faceIDProtectionEnabled =
            false

        selectedMainTab =
            .home

        connectDonorRecordSource =
            .authentication

        currentFlow =
            .accountAccess
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

#Preview {
    ContentView()
}
