//
//  OnboardingView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct OnboardingView: View {

    @State private var currentPage = 0

    var onSkip: () -> Void = {}
    var onFinished: () -> Void = {}

    private var page: OnboardingPage {
        OnboardingPage.pages[currentPage]
    }

    var body: some View {
        VStack(spacing: 0) {

            topControls

            currentVisual

            textContent

            Spacer()

            bottomControls
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(Color("BackgroundPrimary"))
    }

    private var topControls: some View {
        HStack {

            if currentPage == 0 {

                Text("DonorMate SL")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color("DonorRed"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color("DonorRedSoft"))
                    .overlay {
                        Capsule()
                            .stroke(
                                Color("DonorRedBorder"),
                                lineWidth: 1
                            )
                    }
                    .clipShape(Capsule())

            } else {

                Button {
                    currentPage -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(
                            width: 38,
                            height: 38
                        )
                        .background(Color("SurfacePrimary"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color("BorderPrimary"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }

            Spacer()

            Button {
                onSkip()
            } label: {
                Text("Skip")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color("DonorRed"))
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var currentVisual: some View {
        switch page.visualType {

        case .history:
            HistoryOnboardingVisual()
                .padding(.top, 54)

        case .countdown:
            CountdownOnboardingVisual()
                .padding(.top, 36)

        case .nearby:
            NearbyOnboardingVisual()
                .padding(.top, 24)
        }
    }

    private var textContent: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            Text(page.eyebrow.uppercased())
                .font(
                    .system(
                        size: 12,
                        weight: .heavy
                    )
                )
                .foregroundStyle(Color("DonorRed"))

            Text(page.title)
                .font(
                    .system(
                        size: 28,
                        weight: .heavy
                    )
                )
                .foregroundStyle(Color("TextPrimary"))
                .padding(.top, 12)

            Text(page.description)
                .font(.system(size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .lineSpacing(3)
                .padding(.top, 12)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.top, textTopSpacing)
    }

    private var textTopSpacing: CGFloat {
        switch page.visualType {

        case .history:
            return 24

        case .countdown:
            return 30

        case .nearby:
            return 26
        }
    }

    private var bottomControls: some View {
        VStack(spacing: 10) {
            
            pageIndicator
            
            Button {
                handlePrimaryAction()
            } label: {
                
                Text(page.buttonTitle)
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 48
                    )
                    .background(Color("DonorRed"))
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 14
                        )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 26)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {

            ForEach(
                OnboardingPage.pages.indices,
                id: \.self
            ) { index in

                if index == currentPage {

                    Capsule()
                        .fill(Color("DonorRed"))
                        .frame(
                            width: 22,
                            height: 7
                        )

                } else {

                    Circle()
                        .fill(
                            Color("NeutralBorderStrong")
                        )
                        .frame(
                            width: 7,
                            height: 7
                        )
                }
            }
        }
    }

    private func handlePrimaryAction() {
        if currentPage < OnboardingPage.pages.count - 1 {
            currentPage += 1
        } else {
            onFinished()
        }
    }
}

#Preview {
    OnboardingView(
        onSkip: {
            print("Onboarding skipped")
        },
        onFinished: {
            print("Onboarding finished")
        }
    )
}
