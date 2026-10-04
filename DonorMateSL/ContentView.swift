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
    }

    @State private var currentFlow: AppFlow = .splash

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
                        print("Sign In tapped")
                    }
                )

            case .createAccount:
                CreateAccountView(
                    onBack: {
                        currentFlow = .accountAccess
                    },
                    onCreateAccount: {
                        print("Create Account submitted")
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
            }
        }
    }
}

#Preview {
    ContentView()
}
