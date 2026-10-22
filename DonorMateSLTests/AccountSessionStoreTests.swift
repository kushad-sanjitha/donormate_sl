//
//  AccountSessionStoreTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/22/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct AccountSessionStoreTests {

    @Test
    func signInSucceedsWhenAuthCallbackArrivesDuringOperation() async {

        let profile =
            makeProfile(
                uid: "user-a"
            )

        let service =
            FakeAccountService()

        service.signInUserID =
            profile.uid

        service.signInProfile =
            profile

        let store =
            AccountSessionStore(
                accountService: service
            )

        let succeeded =
            await store.signIn(
                email: profile.email,
                password: "password"
            )

        #expect(succeeded)
        #expect(
            store.authenticatedUserID ==
                profile.uid
        )
        #expect(
            store.profile == profile
        )
        #expect(
            store.needsAccountRecovery == false
        )
    }

    @Test
    func wrongCredentialsRemainSignedOut() async {

        let service =
            FakeAccountService()

        service.signInError =
            FakeError.invalidCredentials

        let store =
            AccountSessionStore(
                accountService: service
            )

        let succeeded =
            await store.signIn(
                email: "missing@example.com",
                password: "wrong"
            )

        #expect(succeeded == false)
        #expect(
            store.authenticatedUserID == nil
        )
        #expect(
            store.profile == nil
        )
        #expect(
            store.errorMessage != nil
        )
        #expect(
            store.needsAccountRecovery == false
        )
    }

    @Test
    func authenticatedProfileLoadFailureRequiresRecovery() async {

        let service =
            FakeAccountService()

        service.signInUserID =
            "user-a"

        service.signInError =
            FakeError.offline

        let store =
            AccountSessionStore(
                accountService: service
            )

        let succeeded =
            await store.signIn(
                email: "user@example.com",
                password: "password"
            )

        #expect(succeeded == false)
        #expect(
            store.authenticatedUserID ==
                "user-a"
        )
        #expect(
            store.profile == nil
        )
        #expect(
            store.needsAccountRecovery
        )
    }

    @Test
    func failedProfileCreationKeepsPendingRecoveryProfile() async {

        let profile =
            makeProfile(
                uid: "user-a"
            )

        let service =
            FakeAccountService()

        service.createUserID =
            profile.uid

        service.createError =
            AccountServiceError
                .profileSetupRequired(
                    profile: profile
                )

        let store =
            AccountSessionStore(
                accountService: service
            )

        let succeeded =
            await store.createAccount(
                displayName:
                    profile.displayName,
                email:
                    profile.email,
                password:
                    "password"
            )

        #expect(succeeded == false)
        #expect(
            store.authenticatedUserID ==
                profile.uid
        )
        #expect(
            store.pendingProfile ==
                profile
        )
        #expect(
            store.needsProfileSetup
        )
        #expect(
            store.needsAccountRecovery
        )
    }

    @Test
    func restoredSessionLoadsMatchingProfile() async {

        let profile =
            makeProfile(
                uid: "restored-user"
            )

        let service =
            FakeAccountService()

        service.loadProfile =
            profile

        let store =
            AccountSessionStore(
                accountService: service
            )

        service.emitAuthState(
            profile.uid
        )

        await allowAutomaticWorkToFinish()

        #expect(
            store.isAuthStateResolved
        )
        #expect(
            store.authenticatedUserID ==
                profile.uid
        )
        #expect(
            store.profile == profile
        )
        #expect(
            store.needsAccountRecovery == false
        )
    }

    @Test
    func signOutClearsAccountStateImmediately() async {

        let profile =
            makeProfile(
                uid: "user-a"
            )

        let service =
            FakeAccountService()

        service.signInUserID =
            profile.uid

        service.signInProfile =
            profile

        let store =
            AccountSessionStore(
                accountService: service
            )

        _ = await store.signIn(
            email: profile.email,
            password: "password"
        )

        let succeeded =
            store.signOut()

        #expect(succeeded)
        #expect(
            store.authenticatedUserID == nil
        )
        #expect(
            store.profile == nil
        )
        #expect(
            store.pendingProfile == nil
        )
        #expect(
            store.needsAccountRecovery == false
        )
    }

    @Test
    func staleProfileLoadCannotRestoreDataAfterSignOut() async {

        let profile =
            makeProfile(
                uid: "user-a"
            )

        let service =
            FakeAccountService()

        service.shouldSuspendProfileLoad =
            true

        let store =
            AccountSessionStore(
                accountService: service
            )

        service.emitAuthState(
            profile.uid
        )

        await waitUntil {
            service.hasSuspendedProfileLoad
        }

        let signedOut =
            store.signOut()

        service.resumeSuspendedProfileLoad(
            with: .success(profile)
        )

        await allowAutomaticWorkToFinish()

        #expect(signedOut)
        #expect(
            store.authenticatedUserID == nil
        )
        #expect(
            store.profile == nil
        )
    }

    @Test
    func passwordResetSuccessDoesNotChangeSessionIdentity() async {

        let service =
            FakeAccountService()

        let store =
            AccountSessionStore(
                accountService: service
            )

        let succeeded =
            await store.requestPasswordReset(
                email: "user@example.com"
            )

        #expect(succeeded)
        #expect(
            service.passwordResetEmail ==
                "user@example.com"
        )
        #expect(
            store.authenticatedUserID == nil
        )
        #expect(
            store.errorMessage == nil
        )
    }

    private func makeProfile(
        uid: String
    ) -> AccountProfile {

        AccountProfile(
            uid: uid,
            displayName: "Test User",
            email: "test@example.com"
        )
    }

    private func allowAutomaticWorkToFinish() async {

        for _ in 0..<20 {
            await Task.yield()
        }
    }

    private func waitUntil(
        _ condition: @MainActor () -> Bool
    ) async {

        for _ in 0..<100 {
            if condition() {
                return
            }

            await Task.yield()
        }
    }
}

private enum FakeError:
    LocalizedError {

    case invalidCredentials
    case offline
    case signOutFailed

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials."
        case .offline:
            return "The network is unavailable."
        case .signOutFailed:
            return "Sign out failed."
        }
    }
}

@MainActor
private final class FakeAccountService:
    AccountServicing {

    var currentUserID: String?

    var createUserID: String?
    var createProfile: AccountProfile?
    var createError: Error?

    var signInUserID: String?
    var signInProfile: AccountProfile?
    var signInError: Error?

    var loadProfile: AccountProfile?
    var loadError: Error?

    var completeProfileError: Error?
    var completeCurrentProfileValue: AccountProfile?
    var completeCurrentProfileError: Error?

    var passwordResetEmail: String?
    var passwordResetError: Error?

    var signOutError: Error?

    var shouldSuspendProfileLoad = false

    private var authenticationHandler:
        (@MainActor (String?) -> Void)?

    private var suspendedProfileLoadContinuation:
        CheckedContinuation<
            AccountProfile,
            Error
        >?

    var hasSuspendedProfileLoad: Bool {
        suspendedProfileLoadContinuation != nil
    }

    func createAccount(
        displayName: String,
        email: String,
        password: String
    ) async throws -> AccountProfile {

        if let createUserID {
            emitAuthState(
                createUserID
            )
        }

        if let createError {
            throw createError
        }

        guard let createProfile else {
            throw FakeError.offline
        }

        return createProfile
    }

    func signIn(
        email: String,
        password: String
    ) async throws -> AccountProfile {

        if let signInUserID {
            emitAuthState(
                signInUserID
            )
        }

        if let signInError {
            throw signInError
        }

        guard let signInProfile else {
            throw FakeError.offline
        }

        return signInProfile
    }

    func loadAccountProfile(
        uid: String
    ) async throws -> AccountProfile {

        if shouldSuspendProfileLoad {
            return try await withCheckedThrowingContinuation {
                continuation in

                suspendedProfileLoadContinuation =
                    continuation
            }
        }

        if let loadError {
            throw loadError
        }

        guard let loadProfile else {
            throw FakeError.offline
        }

        return loadProfile
    }

    func completeProfile(
        _ profile: AccountProfile
    ) async throws {

        if let completeProfileError {
            throw completeProfileError
        }
    }

    func completeCurrentProfile(
        displayName: String
    ) async throws -> AccountProfile {

        if let completeCurrentProfileError {
            throw completeCurrentProfileError
        }

        guard let completeCurrentProfileValue else {
            throw FakeError.offline
        }

        return completeCurrentProfileValue
    }

    func sendPasswordReset(
        email: String
    ) async throws {

        passwordResetEmail = email

        if let passwordResetError {
            throw passwordResetError
        }
    }

    func signOut() throws {

        if let signOutError {
            throw signOutError
        }

        currentUserID = nil

        authenticationHandler?(nil)
    }

    func startObservingAuthentication(
        _ handler:
            @escaping @MainActor (String?) -> Void
    ) {
        authenticationHandler = handler
    }

    func stopObservingAuthentication() {
        authenticationHandler = nil
    }

    func emitAuthState(
        _ userID: String?
    ) {

        currentUserID = userID
        authenticationHandler?(userID)
    }

    func resumeSuspendedProfileLoad(
        with result:
            Result<AccountProfile, Error>
    ) {

        guard let continuation =
                suspendedProfileLoadContinuation else {
            return
        }

        suspendedProfileLoadContinuation =
            nil

        switch result {
        case let .success(profile):
            continuation.resume(
                returning: profile
            )

        case let .failure(error):
            continuation.resume(
                throwing: error
            )
        }
    }
}

