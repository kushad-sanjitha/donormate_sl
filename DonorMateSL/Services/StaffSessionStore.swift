//
//  StaffSessionStore.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

@MainActor
protocol StaffAuthenticating {
    func signIn(email: String, password: String) async throws -> StaffIdentity
    func restore() async throws -> StaffIdentity?
    func sendPasswordReset(email: String) async throws
    func signOut() throws
}

nonisolated enum StaffSignInError: LocalizedError, Sendable {
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "This account is not approved for staff access. Contact your blood bank."
        }
    }
}

nonisolated enum StaffAuthFeedback {
    static func signInMessage(for error: Error) -> String {
        if error is StaffSignInError {
            return "This account is not approved for staff access. Contact your blood bank."
        }

        let failure = error as NSError
        if failure.domain == "FIRAuthErrorDomain" {
            switch failure.code {
            case 17004, 17009, 17011:
                return "We couldn't sign you in. Check your email and password."
            case 17008:
                return "Enter a valid email address."
            case 17005:
                return "This account has been disabled. Contact your blood bank."
            case 17010:
                return "Too many attempts. Please wait before trying again."
            case 17020:
                return "Check your internet connection and try again."
            default:
                return "Sign-in could not be completed. Please try again."
            }
        }

        if failure.domain == NSURLErrorDomain {
            return "Check your internet connection and try again."
        }

        return "Staff access could not be checked. Please try again."
    }
}

@MainActor
final class FirebaseStaffAuthService: StaffAuthenticating {
    private let auth: Auth
    private let firestore: Firestore

    init() {
        guard let app = FirebaseApp.app(name: "DonorMateStaff") else {
            preconditionFailure("Configure the named staff Firebase app at startup.")
        }
        auth = Auth.auth(app: app)
        firestore = Firestore.firestore(app: app)
    }

    func signIn(email: String, password: String) async throws -> StaffIdentity {
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanedEmail.isEmpty, !password.isEmpty else { throw StaffSignInError.notAuthorized }
        let result = try await auth.signIn(withEmail: cleanedEmail, password: password)
        do {
            return try await authorizedIdentity(uid: result.user.uid)
        } catch {
            try? auth.signOut()
            throw error
        }
    }

    func restore() async throws -> StaffIdentity? {
        guard let uid = auth.currentUser?.uid else { return nil }
        do {
            return try await authorizedIdentity(uid: uid)
        } catch {
            try? auth.signOut()
            throw error
        }
    }

    func signOut() throws { try auth.signOut() }

    func sendPasswordReset(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    private func authorizedIdentity(uid: String) async throws -> StaffIdentity {
        // A server read prevents a stale cached role from granting staff access.
        let snapshot = try await firestore.collection("staffMembers")
            .document(uid).getDocument(source: .server)
        guard auth.currentUser?.uid == uid,
              let fields = snapshot.data(),
              let identity = StaffRoleValidator.validate(uid: uid, fields: fields) else {
            throw StaffSignInError.notAuthorized
        }
        return identity
    }
}

@MainActor
final class StaffSessionStore: ObservableObject {
    @Published private(set) var staff: StaffIdentity?
    @Published private(set) var isResolving = true
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let auth: StaffAuthenticating

    init(auth: StaffAuthenticating? = nil) {
        self.auth = auth ?? FirebaseStaffAuthService()
        Task { await restoreSession() }
    }

    func clearError() {
        errorMessage = nil
    }

    func signIn(email: String, password: String) async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            staff = try await auth.signIn(email: email, password: password)
            return true
        } catch {
            staff = nil
            errorMessage = StaffAuthFeedback.signInMessage(for: error)
            return false
        }
    }

    func sendPasswordReset(email: String) async -> Bool {
        guard !isLoading else { return false }
        let cleanedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedEmail.isEmpty else { return false }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await auth.sendPasswordReset(email: cleanedEmail)
            return true
        } catch {
            errorMessage = "Password reset is unavailable right now. Please try again later."
            return false
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            staff = nil
            errorMessage = nil
        } catch {
            errorMessage = "Staff sign-out could not complete. Please try again."
        }
    }

    private func restoreSession() async {
        defer { isResolving = false }
        do {
            staff = try await auth.restore()
        } catch {
            staff = nil
            errorMessage = "Staff authorization could not be confirmed. Sign in when online."
        }
    }
}
