//
//  BiometricAuthenticationService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import Foundation
import LocalAuthentication
import Combine

enum BiometricAuthenticationState {
    case available
    case unavailable
    case authenticationSucceeded
    case authenticationFailed
}

@MainActor
final class BiometricAuthenticationService: ObservableObject {

    @Published private(set) var state: BiometricAuthenticationState = .unavailable

    func refreshAvailability() {
        let context = LAContext()
        var error: NSError?

        let canAuthenticate = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        if canAuthenticate && context.biometryType == .faceID {
            state = .available
        } else {
            state = .unavailable
        }
    }

    func authenticateWithFaceID() async -> BiometricAuthenticationState {
        let context = LAContext()
        var error: NSError?

        let canAuthenticate = context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: &error
        )

        guard canAuthenticate,
              context.biometryType == .faceID else {

            state = .unavailable
            return .unavailable
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Use Face ID to protect access to your personal donor information."
            )

            if success {
                state = .authenticationSucceeded
                return .authenticationSucceeded
            } else {
                state = .authenticationFailed
                return .authenticationFailed
            }

        } catch {
            state = .authenticationFailed
            return .authenticationFailed
        }
    }
}
