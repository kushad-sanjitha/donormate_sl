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
        case staffSignIn
        case staffWorkspace
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

    @State private var restorationToken: UUID?
    @State private var restorationUserID: String?
    @State private var loadedDonorUserID: String?

    @StateObject private var donorRecordsStore = DonorRecordsStore()
    @StateObject private var donationLocationStore = DonationLocationStore()
    @StateObject private var urgentBloodNeedStore = UrgentBloodNeedStore()
    @StateObject private var savedItemsStore = SavedItemsStore()
    @StateObject private var notificationInboxStore = NotificationInboxStore.shared
    @StateObject private var notificationPreferencesStore = NotificationPreferencesStore.shared
    @StateObject private var accountSetupStore = AccountSetupStore()
    @StateObject private var staffSessionStore = StaffSessionStore()

    private let donorRecordProvider = DemoDonorRecordProvider()

    @StateObject private var accountSessionStore =
        AccountSessionStore()

    @StateObject private var locationPermissionService =
        LocationPermissionService()

    @StateObject private var notificationPermissionService =
        NotificationPermissionService()

    @StateObject private var biometricAuthenticationService =
        BiometricAuthenticationService()

    @State private var faceIDUnavailable = false

    private var faceIDStatus:
        FaceIDSetupStatus {

        if faceIDUnavailable {
            return .unavailable
        }

        if accountSetupStore.faceIDProtectionEnabled {
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
                    },
                    onStaffSignIn: {
                        currentFlow = .staffSignIn
                    }
                )

            case .staffSignIn:
                StaffSignInView(
                    isLoading: staffSessionStore.isLoading,
                    errorMessage: staffSessionStore.errorMessage,
                    onSignIn: { email, password in
                        if await staffSessionStore.signIn(email: email, password: password) {
                            currentFlow = .staffWorkspace
                        }
                    },
                    onForgotPassword: { email in
                        await staffSessionStore.sendPasswordReset(email: email)
                    },
                    onEdit: { staffSessionStore.clearError() },
                    onBack: { currentFlow = .accountAccess }
                )

            case .staffWorkspace:
                if let staff = staffSessionStore.staff {
                    StaffWorkspaceView(
                        staff: staff,
                        onExit: {
                            staffSessionStore.signOut()
                            if staffSessionStore.staff == nil {
                                currentFlow = .accountAccess
                            }
                        }
                    )
                } else {
                    ProgressView("Checking staff authorization")
                        .task { currentFlow = .staffSignIn }
                }

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

                        openAuthenticatedEntryFlow()
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

                        openAuthenticatedEntryFlow()
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
                        if accountSetupStore.faceIDProtectionEnabled {
                            accountSetupStore.completeInitialSetup()
                            currentFlow = .mainApp
                        } else {
                            currentFlow = .faceIDSetup
                        }
                    }
                )

            case .faceIDSetup:
                FaceIDSetupView(
                    onBack: {
                        currentFlow =
                            .permissionSetup
                    },
                    onEnableFaceID: {
                        guard let expectedUserID = validAccountProfile?.uid else { return }
                        Task {
                            let result =
                                await biometricAuthenticationService
                                    .authenticateWithFaceID()

                            guard validAccountProfile?.uid == expectedUserID,
                                  accountSetupStore.activeUserID == expectedUserID else { return }

                            switch result {

                            case .authenticationSucceeded:
                                accountSetupStore.setFaceIDProtectionEnabled(true)
                                accountSetupStore.completeInitialSetup()

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
                        accountSetupStore.completeInitialSetup()
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
                        accountSetupStore.completeInitialSetup()
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
        .environmentObject(accountSetupStore)
        .onAppear {
            refreshSetupStatuses()
            accountSetupStore.activate(for: accountSessionStore.authenticatedUserID)
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
        .onChange(of: staffSessionStore.isResolving) { _, resolving in
            if !resolving && waitingForSessionResolution {
                routeAfterSplash()
            }
        }
        .onChange(of: staffSessionStore.staff?.uid) { _, uid in
            if uid == nil && currentFlow == .staffWorkspace {
                currentFlow = .staffSignIn
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

        if staffSessionStore.isResolving {
            waitingForSessionResolution = true
            return
        }

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

        guard !staffSessionStore.isResolving else {
            waitingForSessionResolution = true
            return
        }

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

        if staffSessionStore.staff != nil {
            currentFlow = .staffWorkspace
            return
        }

        guard accountSessionStore
            .authenticatedUserID != nil else {

            currentFlow =
                .onboarding

            return
        }

        if hasValidAccountProfile {
            accountSetupStore.activate(for: validAccountProfile?.uid)

            if accountSetupStore.faceIDProtectionEnabled {
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

            if restorationUserID != newUserID {
                restorationToken = nil
                restorationUserID = nil
            }

            if loadedDonorUserID != newUserID {
                donorRecordsStore.unlink()
                loadedDonorUserID = nil
            }

            accountSetupStore.activate(for: newUserID)
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

        if currentFlow == .staffWorkspace {
            if staffSessionStore.staff == nil && !staffSessionStore.isResolving {
                currentFlow = .staffSignIn
            }
            return
        }

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
            loadedDonorUserID = nil

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
        loadedDonorUserID = nil

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

            accountSetupStore.activate(for: account.uid)
            guard accountSetupStore.rememberLinkedRecordID(donorRecordID) else {
                return false
            }

            donorRecordsStore.replaceLinkedData(
                profile: result.profile,
                records: result.records,
                isVerified: result.isVerified
            )
            loadedDonorUserID = account.uid
            return true
        } catch {
            return false
        }
    }

    private func openAuthenticatedEntryFlow() {

        guard let account = validAccountProfile else {
            currentFlow = .accountRecovery
            return
        }

        accountSetupStore.activate(for: account.uid)

        connectDonorRecordSource =
            .authentication

        guard restorationToken == nil else { return }

        guard let recordID = accountSetupStore.linkedDonorRecordID else {
            currentFlow = accountSetupStore.hasCompletedInitialSetup
                ? .mainApp : .connectDonorRecord
            return
        }

        let expectedToken = UUID()
        restorationToken = expectedToken
        restorationUserID = account.uid
        let initialSetupComplete = accountSetupStore.hasCompletedInitialSetup

        Task {
            // Re-fetch via the existing provider. A saved ID never implies
            // a verified record or authorizes access to medical information.
            let result = try? await donorRecordProvider.findRecord(
                account: account,
                donorRecordID: recordID
            )

            guard restorationToken == expectedToken,
                  accountSetupStore.activeUserID == account.uid,
                  validAccountProfile?.uid == account.uid else { return }

            restorationToken = nil
            restorationUserID = nil

            if let result {
                donorRecordsStore.replaceLinkedData(
                    profile: result.profile,
                    records: result.records,
                    isVerified: result.isVerified
                )
                loadedDonorUserID = account.uid
            }

            if initialSetupComplete {
                currentFlow = .mainApp
            } else {
                currentFlow = result == nil ? .connectDonorRecord : .donorRecordLinked
            }
        }
    }

    private func requestRestoredSessionUnlock() {

        guard accountSetupStore.faceIDProtectionEnabled else {
            openAuthenticatedEntryFlow()
            return
        }

        guard let expectedUserID = validAccountProfile?.uid else {
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

            guard validAccountProfile?.uid == expectedUserID,
                  accountSetupStore.activeUserID == expectedUserID else { return }

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
        loadedDonorUserID = nil
        restorationToken = nil
        restorationUserID = nil
        accountSetupStore.activate(for: nil)

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
        loadedDonorUserID = nil
        restorationToken = nil
        restorationUserID = nil
        accountSetupStore.activate(for: nil)

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
        loadedDonorUserID = nil
        accountSetupStore.forgetLinkedRecordID()

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
             .staffSignIn,
             .staffWorkspace,
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
