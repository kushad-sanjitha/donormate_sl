//
//  AccountSessionStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import Foundation
import Combine

@MainActor
final class AccountSessionStore:
    ObservableObject {

    @Published private(set)
    var authenticatedUserID: String?

    @Published private(set)
    var profile: AccountProfile?

    @Published private(set)
    var pendingProfile:
        AccountProfile?

    @Published private(set)
    var isLoading = false

    @Published private(set)
    var errorMessage: String?

    @Published private(set)
    var isAuthStateResolved = false

    @Published private(set)
    var requiresProfileName = false

    @Published private(set)
    var requiresNationalIdentityNumber = false

    @Published private(set)
    var recoveryDisplayName: String?

    private let accountService:
        AccountServicing

    private var sessionGeneration = 0

    private var manualOperationID: UUID?

    private var manualAuthenticationOperationID:
        UUID?

    private var activeAutomaticLoadID: UUID?

    private var profileLoadTask:
        Task<Void, Never>?

    private var deferredProfileUserID:
        String?

    init(
        accountService: AccountServicing? = nil
    ) {

        self.accountService =
            accountService
            ?? FirebaseAccountService()

        startAuthenticationObservation()
    }

    var isAuthenticated: Bool {
        authenticatedUserID != nil
    }

    var hasLoadedProfile: Bool {
        profile != nil
    }

    var needsProfileSetup: Bool {
        pendingProfile != nil
        || requiresProfileName
        || requiresNationalIdentityNumber
    }

    var needsAccountRecovery: Bool {
        guard let authenticatedUserID else {
            return false
        }

        guard let profile,
              profile.uid ==
                authenticatedUserID else {
            return true
        }

        return !profile.hasNationalIdentityNumber
            || requiresProfileName
            || requiresNationalIdentityNumber
    }

    func createAccount(
        displayName: String,
        nationalIdentityNumber: String,
        email: String,
        password: String
    ) async -> Bool {

        guard !isLoading else {
            return false
        }

        let operationID =
            beginManualOperation(
                isAuthentication: true
            )

        defer {
            finishManualOperation(
                operationID
            )
        }

        do {
            let loadedProfile =
                try await accountService
                    .createAccount(
                        displayName:
                            displayName,
                        nationalIdentityNumber:
                            nationalIdentityNumber,
                        email:
                            email,
                        password:
                            password
                    )

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            guard accountService
                    .currentUserID ==
                    loadedProfile.uid else {

                return false
            }

            applyLoadedProfile(
                loadedProfile
            )

            deferredProfileUserID = nil

            return true

        } catch let error
                    as AccountServiceError {

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            handleManualOperationError(
                error
            )

            return false

        } catch {

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            synchronizeWithCurrentFirebaseUser()

            errorMessage =
                error.localizedDescription

            return false
        }
    }

    func signIn(
        email: String,
        password: String
    ) async -> Bool {

        guard !isLoading else {
            return false
        }

        let operationID =
            beginManualOperation(
                isAuthentication: true
            )

        defer {
            finishManualOperation(
                operationID
            )
        }

        do {
            let loadedProfile =
                try await accountService
                    .signIn(
                        email: email,
                        password: password
                    )

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            guard accountService
                    .currentUserID ==
                    loadedProfile.uid else {

                return false
            }

            applyLoadedProfile(
                loadedProfile
            )

            deferredProfileUserID = nil

            return true

        } catch let error
                    as AccountServiceError {

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            handleManualOperationError(
                error
            )

            return false

        } catch {

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            synchronizeWithCurrentFirebaseUser()

            errorMessage =
                error.localizedDescription

            return false
        }
    }

    func retryProfileSetup()
        async -> Bool {

        guard !isLoading else {
            return false
        }

        guard let pendingProfile else {
            return false
        }

        let expectedUserID =
            pendingProfile.uid

        guard accountService
                .currentUserID ==
                expectedUserID else {

            return false
        }

        let expectedGeneration =
            sessionGeneration

        let operationID =
            beginManualOperation(
                isAuthentication: false
            )

        defer {
            finishManualOperation(
                operationID
            )
        }

        do {
            try await accountService
                .completeProfile(
                    pendingProfile
                )

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID else {

                return false
            }

            applyLoadedProfile(
                pendingProfile
            )

            return true

        } catch {

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID else {

                return false
            }

            errorMessage =
                error.localizedDescription

            return false
        }
    }

    func completeMissingProfile(
        displayName: String,
        nationalIdentityNumber: String
    ) async -> Bool {

        guard !isLoading else {
            return false
        }

        guard let expectedUserID =
                authenticatedUserID,
              accountService
                .currentUserID ==
                expectedUserID else {

            return false
        }

        let expectedGeneration =
            sessionGeneration

        let operationID =
            beginManualOperation(
                isAuthentication: false
            )

        defer {
            finishManualOperation(
                operationID
            )
        }

        do {
            let completedProfile =
                try await accountService
                    .completeCurrentProfile(
                        displayName:
                            displayName,
                        nationalIdentityNumber:
                            nationalIdentityNumber
                    )

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID,
            completedProfile.uid ==
                expectedUserID else {

                return false
            }

            applyLoadedProfile(
                completedProfile
            )

            return true

        } catch let error
                    as AccountServiceError {

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID else {

                return false
            }

            handleAccountServiceError(
                error,
                expectedUserID:
                    expectedUserID,
                generation:
                    expectedGeneration
            )

            return false

        } catch {

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID else {

                return false
            }

            errorMessage =
                error.localizedDescription

            return false
        }
    }

    func retryProfileLoad()
        async -> Bool {

        guard !isLoading else {
            return false
        }

        guard let expectedUserID =
                authenticatedUserID,
              accountService
                .currentUserID ==
                expectedUserID else {

            return false
        }

        let expectedGeneration =
            sessionGeneration

        let operationID =
            beginManualOperation(
                isAuthentication: false
            )

        defer {
            finishManualOperation(
                operationID
            )
        }

        do {
            let loadedProfile =
                try await accountService
                    .loadAccountProfile(
                        uid:
                            expectedUserID
                    )

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID,
            loadedProfile.uid ==
                expectedUserID else {

                return false
            }

            applyLoadedProfile(
                loadedProfile
            )

            return true

        } catch let error
                    as AccountServiceError {

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID else {

                return false
            }

            handleAccountServiceError(
                error,
                expectedUserID:
                    expectedUserID,
                generation:
                    expectedGeneration
            )

            return false

        } catch {

            guard isManualOperationCurrent(
                operationID
            ),
            sessionGeneration ==
                expectedGeneration,
            accountService
                .currentUserID ==
                expectedUserID else {

                return false
            }

            errorMessage =
                error.localizedDescription

            return false
        }
    }


    func requestPasswordReset(
        email: String
    ) async -> Bool {

        guard !isLoading else {
            return false
        }

        let operationID =
            beginManualOperation(
                isAuthentication: false
            )

        defer {
            finishManualOperation(
                operationID
            )
        }

        do {
            try await accountService
                .sendPasswordReset(
                    email: email
                )

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            errorMessage = nil
            return true

        } catch {

            guard isManualOperationCurrent(
                operationID
            ) else {
                return false
            }

            errorMessage =
                error.localizedDescription

            return false
        }
    }

    @discardableResult
    func signOut() -> Bool {

        do {
            try accountService
                .signOut()

            invalidateSessionWork()

            clearAccountStateAfterSignOut()

            isAuthStateResolved = true

            return true

        } catch {

            errorMessage =
                error.localizedDescription

            return false
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func startAuthenticationObservation() {

        accountService
            .startObservingAuthentication {
                [weak self]
                observedUserID in

                guard let self else {
                    return
                }

                handleAuthenticationChange(
                    observedUserID
                )
            }
    }

    private func handleAuthenticationChange(
        _ observedUserID: String?
    ) {

        let currentFirebaseUserID =
            accountService
                .currentUserID

        guard observedUserID ==
                currentFirebaseUserID else {

            return
        }

        isAuthStateResolved = true

        if authenticatedUserID ==
            observedUserID {

            guard let observedUserID else {
                return
            }

            guard profile?.uid !=
                    observedUserID,
                  pendingProfile?.uid !=
                    observedUserID else {

                return
            }

            if isLoading {

                deferredProfileUserID =
                    observedUserID

                return
            }

            startProfileLoad(
                for:
                    observedUserID
            )

            return
        }

        if let manualAuthenticationOperationID,
           manualOperationID ==
                manualAuthenticationOperationID,
           let observedUserID {

            authenticatedUserID =
                observedUserID

            if profile?.uid !=
                observedUserID {

                profile = nil
            }

            if pendingProfile?.uid !=
                observedUserID {

                pendingProfile = nil
            }

            requiresProfileName = false
            requiresNationalIdentityNumber = false
            recoveryDisplayName = nil
            errorMessage = nil

            deferredProfileUserID =
                observedUserID

            return
        }

        invalidateSessionWork()

        authenticatedUserID =
            observedUserID

        if profile?.uid !=
            observedUserID {

            profile = nil
        }

        if pendingProfile?.uid !=
            observedUserID {

            pendingProfile = nil
        }

        requiresProfileName = false
        requiresNationalIdentityNumber = false
        recoveryDisplayName = nil
        errorMessage = nil

        guard let observedUserID else {

            clearAccountStateAfterSignOut()
            return
        }

        startProfileLoad(
            for:
                observedUserID
        )
    }

    private func startProfileLoad(
        for userID: String
    ) {

        guard accountService
                .currentUserID ==
                userID else {

            return
        }

        retireAutomaticLoad()

        let loadID =
            UUID()

        activeAutomaticLoadID =
            loadID

        let expectedGeneration =
            sessionGeneration

        refreshLoadingState()

        profileLoadTask =
            Task { [weak self] in

                guard let self else {
                    return
                }

                defer {
                    finishAutomaticProfileLoad(
                        loadID:
                            loadID
                    )
                }

                do {
                    let loadedProfile =
                        try await accountService
                            .loadAccountProfile(
                                uid:
                                    userID
                            )

                    guard isAutomaticLoadCurrent(
                        loadID:
                            loadID,
                        uid:
                            userID,
                        generation:
                            expectedGeneration
                    ),
                    loadedProfile.uid ==
                        userID else {

                        return
                    }

                    applyLoadedProfile(
                        loadedProfile
                    )

                } catch let error
                            as AccountServiceError {

                    guard isAutomaticLoadCurrent(
                        loadID:
                            loadID,
                        uid:
                            userID,
                        generation:
                            expectedGeneration
                    ) else {

                        return
                    }

                    handleAccountServiceError(
                        error,
                        expectedUserID:
                            userID,
                        generation:
                            expectedGeneration
                    )

                } catch {

                    guard isAutomaticLoadCurrent(
                        loadID:
                            loadID,
                        uid:
                            userID,
                        generation:
                            expectedGeneration
                    ) else {

                        return
                    }

                    profile = nil

                    errorMessage =
                        error.localizedDescription
                }
            }
    }

    private func beginManualOperation(
        isAuthentication: Bool
    ) -> UUID {

        let operationID =
            UUID()

        manualOperationID =
            operationID

        if isAuthentication {

            manualAuthenticationOperationID =
                operationID
        }

        errorMessage = nil

        refreshLoadingState()

        return operationID
    }

    private func finishManualOperation(
        _ operationID: UUID
    ) {

        guard manualOperationID ==
                operationID else {

            return
        }

        manualOperationID = nil

        if manualAuthenticationOperationID ==
            operationID {

            manualAuthenticationOperationID =
                nil
        }

        refreshLoadingState()

        processDeferredProfileLoad()
    }

    private func invalidateManualOperation() {

        manualOperationID = nil

        manualAuthenticationOperationID =
            nil

        refreshLoadingState()
    }

    private func finishAutomaticProfileLoad(
        loadID: UUID
    ) {

        guard activeAutomaticLoadID ==
                loadID else {

            return
        }

        activeAutomaticLoadID = nil
        profileLoadTask = nil

        refreshLoadingState()

        processDeferredProfileLoad()
    }

    private func retireAutomaticLoad() {

        activeAutomaticLoadID =
            nil

        profileLoadTask?.cancel()

        profileLoadTask = nil

        refreshLoadingState()
    }

    private func invalidateSessionWork() {

        sessionGeneration += 1

        invalidateManualOperation()

        retireAutomaticLoad()

        deferredProfileUserID = nil
    }

    private func processDeferredProfileLoad() {

        guard !isLoading else {
            return
        }

        guard let userID =
                deferredProfileUserID else {

            return
        }

        deferredProfileUserID = nil

        guard authenticatedUserID ==
                userID,
              accountService
                .currentUserID ==
                userID else {

            return
        }

        if profile?.uid ==
            userID {

            return
        }

        if pendingProfile?.uid ==
            userID {

            return
        }

        startProfileLoad(
            for:
                userID
        )
    }

    private func refreshLoadingState() {

        isLoading =
            manualOperationID != nil
            || activeAutomaticLoadID != nil
    }

    private func clearAccountStateAfterSignOut() {

        authenticatedUserID = nil
        profile = nil
        pendingProfile = nil

        requiresProfileName = false
        requiresNationalIdentityNumber = false
        recoveryDisplayName = nil
        errorMessage = nil

        deferredProfileUserID = nil

        refreshLoadingState()
    }

    private func synchronizeWithCurrentFirebaseUser() {

        let currentUserID =
            accountService
                .currentUserID

        authenticatedUserID =
            currentUserID

        guard let currentUserID else {

            profile = nil
            pendingProfile = nil
            requiresProfileName = false
            requiresNationalIdentityNumber = false
            recoveryDisplayName = nil

            return
        }

        if profile?.uid !=
            currentUserID {

            profile = nil
        }

        if pendingProfile?.uid !=
            currentUserID {

            pendingProfile = nil
        }
    }

    private func handleManualOperationError(
        _ error: AccountServiceError
    ) {

        guard let currentUserID =
                accountService
                    .currentUserID else {

            authenticatedUserID = nil
            profile = nil
            pendingProfile = nil

            requiresProfileName = false
            requiresNationalIdentityNumber = false
            recoveryDisplayName = nil

            errorMessage =
                error.localizedDescription

            return
        }

        authenticatedUserID =
            currentUserID

        if profile?.uid !=
            currentUserID {

            profile = nil
        }

        handleAccountServiceError(
            error,
            expectedUserID:
                currentUserID,
            generation:
                sessionGeneration
        )
    }

    private func handleAccountServiceError(
        _ error: AccountServiceError,
        expectedUserID: String,
        generation: Int
    ) {

        guard sessionGeneration ==
                generation,
              accountService
                .currentUserID ==
                expectedUserID else {

            return
        }

        authenticatedUserID =
            expectedUserID

        switch error {

        case let .profileSetupRequired(
            pendingProfile
        ):

            guard pendingProfile.uid ==
                    expectedUserID else {

                return
            }

            profile = nil

            self.pendingProfile =
                pendingProfile

            requiresProfileName = false
            requiresNationalIdentityNumber =
                !pendingProfile.hasNationalIdentityNumber
            recoveryDisplayName =
                pendingProfile.displayName

        case let .profileRecoveryRequired(
            displayName
        ):

            profile = nil
            pendingProfile = nil

            requiresProfileName =
                displayName == nil
            requiresNationalIdentityNumber = true
            recoveryDisplayName =
                displayName

        default:

            if profile?.uid !=
                expectedUserID {

                profile = nil
            }

            if pendingProfile?.uid !=
                expectedUserID {

                pendingProfile = nil
            }

            requiresProfileName = false
            requiresNationalIdentityNumber = false
            recoveryDisplayName = nil
        }

        errorMessage =
            error.localizedDescription
    }

    private func applyLoadedProfile(
        _ loadedProfile: AccountProfile
    ) {

        authenticatedUserID =
            loadedProfile.uid

        profile =
            loadedProfile

        pendingProfile = nil

        requiresProfileName = false
        requiresNationalIdentityNumber =
            !loadedProfile.hasNationalIdentityNumber

        recoveryDisplayName =
            loadedProfile.displayName

        errorMessage = nil
    }

    private func isManualOperationCurrent(
        _ operationID: UUID
    ) -> Bool {

        manualOperationID ==
            operationID
    }

    private func isAutomaticLoadCurrent(
        loadID: UUID,
        uid: String,
        generation: Int
    ) -> Bool {

        activeAutomaticLoadID ==
            loadID
        && sessionGeneration ==
            generation
        && authenticatedUserID ==
            uid
        && accountService
            .currentUserID ==
            uid
    }
}
