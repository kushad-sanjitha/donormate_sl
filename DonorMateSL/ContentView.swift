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
                           print("Create Account tapped")
                       }
                   )

               case .signIn:
                   SignInView(
                       onBack: {
                           currentFlow = .accountAccess
                       },
                       onForgotPassword: {
                           print("Forgot password tapped")
                       },
                       onCreateAccount: {
                           print("Create account tapped")
                       },
                       onSignIn: {
                           print("Sign In tapped")
                       }
                   )
               }
           }
       }
   }

   #Preview {
       ContentView()
   }
