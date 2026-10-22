//
//  FirebaseAccountService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

nonisolated enum AccountServiceError:
    LocalizedError,
    Sendable {

    case invalidDisplayName
    case invalidEmail
    case missingAuthenticatedUser
    case missingEmail
    case profileNotFound
    case invalidProfile

    case profileSetupRequired(
        profile: AccountProfile
    )

    case profileRecoveryRequired

    var errorDescription: String? {

        switch self {

        case .invalidDisplayName:
            return "Enter a valid full name between 1 and 80 characters."

        case .invalidEmail:
            return "Enter a valid email address."

        case .missingAuthenticatedUser:
            return "No authenticated account is available."

        case .missingEmail:
            return "The authenticated account does not have an email address."

        case .profileNotFound:
            return "Your account profile could not be found."

        case .invalidProfile:
            return "Your account profile contains invalid information."

        case .profileSetupRequired:
            return "Your account is signed in, but profile setup could not be completed. Please try again."

        case .profileRecoveryRequired:
            return "Your account is signed in, but your full name is required to finish profile setup."
        }
    }
}

@MainActor
protocol AccountServicing: AnyObject {

    var currentUserID: String? {
        get
    }

    func createAccount(
        displayName: String,
        email: String,
        password: String
    ) async throws -> AccountProfile

    func signIn(
        email: String,
        password: String
    ) async throws -> AccountProfile

    func loadAccountProfile(
        uid: String
    ) async throws -> AccountProfile

    func completeProfile(
        _ profile: AccountProfile
    ) async throws

    func completeCurrentProfile(
        displayName: String
    ) async throws -> AccountProfile

    func sendPasswordReset(
        email: String
    ) async throws

    func signOut() throws

    func startObservingAuthentication(
        _ handler:
            @escaping @MainActor (String?) -> Void
    )

    func stopObservingAuthentication()
}

@MainActor
final class FirebaseAccountService:
    AccountServicing {

    private let auth: Auth
    private let firestore: Firestore

    private var authStateHandle:
        AuthStateDidChangeListenerHandle?

    init(
        auth: Auth = Auth.auth(),
        firestore: Firestore =
            Firestore.firestore()
    ) {
        self.auth = auth
        self.firestore = firestore
    }

    var currentUserID: String? {
        auth.currentUser?.uid
    }

    func createAccount(
        displayName: String,
        email: String,
        password: String
    ) async throws -> AccountProfile {

        let cleanedName =
            try validatedDisplayName(
                displayName
            )

        let cleanedEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        let result =
            try await auth.createUser(
                withEmail: cleanedEmail,
                password: password
            )

        guard let authenticatedEmail =
                result.user.email else {

            throw AccountServiceError
                .missingEmail
        }

        let profile =
            AccountProfile(
                uid: result.user.uid,
                displayName: cleanedName,
                email: authenticatedEmail
            )

        do {
            try await completeProfile(
                profile
            )

            return profile

        } catch {

            throw AccountServiceError
                .profileSetupRequired(
                    profile: profile
                )
        }
    }

    func signIn(
        email: String,
        password: String
    ) async throws -> AccountProfile {

        let cleanedEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        let result =
            try await auth.signIn(
                withEmail: cleanedEmail,
                password: password
            )

        return try await loadAccountProfile(
            uid: result.user.uid
        )
    }

    func loadAccountProfile(
        uid: String
    ) async throws -> AccountProfile {

        guard let currentUser =
                auth.currentUser,
              currentUser.uid == uid else {

            throw AccountServiceError
                .missingAuthenticatedUser
        }

        do {
            return try await loadProfileDocument(
                uid: uid
            )

        } catch AccountServiceError
                    .profileNotFound {

            return try await recoverMissingProfile(
                for: currentUser
            )
        }
    }

    func completeProfile(
        _ profile: AccountProfile
    ) async throws {

        guard let currentUser =
                auth.currentUser,
              currentUser.uid ==
                profile.uid else {

            throw AccountServiceError
                .missingAuthenticatedUser
        }

        let cleanedName =
            try validatedDisplayName(
                profile.displayName
            )

        guard let authenticatedEmail =
                currentUser.email else {

            throw AccountServiceError
                .missingEmail
        }

        let changeRequest =
            currentUser
                .createProfileChangeRequest()

        changeRequest.displayName =
            cleanedName

        try await changeRequest
            .commitChanges()

        let document =
            firestore
                .collection("users")
                .document(profile.uid)

        let snapshot =
            try await document
                .getDocument()

        guard auth.currentUser?.uid ==
                profile.uid else {

            throw AccountServiceError
                .missingAuthenticatedUser
        }

        if snapshot.exists {

            try await document
                .updateData(
                    [
                        "displayName":
                            cleanedName
                    ]
                )

        } else {

            try await document
                .setData(
                    [
                        "displayName":
                            cleanedName,
                        "email":
                            authenticatedEmail,
                        "createdAt":
                            FieldValue
                                .serverTimestamp()
                    ]
                )
        }
    }

    func completeCurrentProfile(
        displayName: String
    ) async throws -> AccountProfile {

        guard let currentUser =
                auth.currentUser else {

            throw AccountServiceError
                .missingAuthenticatedUser
        }

        guard let email =
                currentUser.email else {

            throw AccountServiceError
                .missingEmail
        }

        let cleanedName =
            try validatedDisplayName(
                displayName
            )

        let profile =
            AccountProfile(
                uid: currentUser.uid,
                displayName: cleanedName,
                email: email
            )

        try await completeProfile(
            profile
        )

        return profile
    }

    func sendPasswordReset(
        email: String
    ) async throws {

        let cleanedEmail =
            email
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        guard !cleanedEmail.isEmpty else {
            throw AccountServiceError
                .invalidEmail
        }

        try await auth.sendPasswordReset(
            withEmail: cleanedEmail
        )
    }

    func signOut() throws {
        try auth.signOut()
    }

    func startObservingAuthentication(
        _ handler:
            @escaping @MainActor (String?) -> Void
    ) {

        stopObservingAuthentication()

        authStateHandle =
            auth.addStateDidChangeListener {
                _,
                user in

                let userID =
                    user?.uid

                Task { @MainActor in
                    handler(
                        userID
                    )
                }
            }
    }

    func stopObservingAuthentication() {

        guard let authStateHandle else {
            return
        }

        auth.removeStateDidChangeListener(
            authStateHandle
        )

        self.authStateHandle = nil
    }

    private func loadProfileDocument(
        uid: String
    ) async throws -> AccountProfile {

        let snapshot =
            try await firestore
                .collection("users")
                .document(uid)
                .getDocument()

        guard snapshot.exists else {

            throw AccountServiceError
                .profileNotFound
        }

        guard let data =
                snapshot.data(),
              let displayName =
                data["displayName"]
                    as? String,
              let email =
                data["email"]
                    as? String else {

            throw AccountServiceError
                .invalidProfile
        }

        let cleanedName =
            try validatedDisplayName(
                displayName
            )

        guard !email.isEmpty else {

            throw AccountServiceError
                .invalidProfile
        }

        return AccountProfile(
            uid: uid,
            displayName: cleanedName,
            email: email
        )
    }

    private func recoverMissingProfile(
        for user: User
    ) async throws -> AccountProfile {

        guard auth.currentUser?.uid ==
                user.uid else {

            throw AccountServiceError
                .missingAuthenticatedUser
        }

        guard let email =
                user.email else {

            throw AccountServiceError
                .missingEmail
        }

        guard let displayName =
                user.displayName else {

            throw AccountServiceError
                .profileRecoveryRequired
        }

        let cleanedName =
            try validatedDisplayName(
                displayName
            )

        let profile =
            AccountProfile(
                uid: user.uid,
                displayName: cleanedName,
                email: email
            )

        do {
            try await completeProfile(
                profile
            )

            return profile

        } catch {

            throw AccountServiceError
                .profileSetupRequired(
                    profile: profile
                )
        }
    }

    private func validatedDisplayName(
        _ displayName: String
    ) throws -> String {

        let cleanedName =
            displayName
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

        guard !cleanedName.isEmpty,
              cleanedName.count <= 80 else {

            throw AccountServiceError
                .invalidDisplayName
        }

        return cleanedName
    }
}

