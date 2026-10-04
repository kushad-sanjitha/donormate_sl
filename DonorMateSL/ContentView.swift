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
                        print("Onboarding finished")
                    },
                    onFinished: {
                        print("Onboarding finished")
                    }
                )
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
