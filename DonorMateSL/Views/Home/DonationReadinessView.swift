//
//  DonationReadinessView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct DonationReadinessView: View {

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.scenePhase)
    private var scenePhase

    @ObservedObject var donorRecordsStore:
        DonorRecordsStore

    var onFindNearby: () -> Void = {}

    @State private var currentDate = Date()

    private let calendar = Calendar.current

    private var presentation:
        DonationReadinessPresentation {

        DonationReadinessPresentationBuilder
            .presentation(
                linkState:
                    donorRecordsStore.linkState,
                latestRecord:
                    donorRecordsStore.latestRecord,
                currentDate:
                    currentDate,
                calendar:
                    calendar
            )
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Donation Readiness",
                onBack: {
                    dismiss()
                }
            )

            ScreenScrollView {
                VStack(spacing: 0) {

                readinessSummary

                Spacer()
                    .frame(height: 16)

                Text("Before you donate")
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        Color("TextPrimary")
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Confirm the current donation requirements.",
                    style: .check
                )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Bring valid identification.",
                    style: .check
                )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Follow official preparation guidance.",
                    style: .check
                )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Final medical eligibility is always confirmed by authorised blood-bank staff.",
                    style: .warning
                )

                Spacer()
                    .frame(height: 16)

                Button {
                    onFindNearby()
                } label: {
                    Text("Find Nearby Donation")
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
                        .background(
                            Color("DonorRed")
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 14
                            )
                        )
                }
                .buttonStyle(.plain)

                Spacer()
                    .frame(height: 28)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        }
        .background(
            Color("BackgroundPrimary")
        )
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            currentDate = Date()
        }
        .onChange(of: scenePhase) {
            _, newPhase in

            if newPhase == .active {
                currentDate = Date()
            }
        }
    }

    private var readinessSummary: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            Text(presentation.badgeTitle)
                .font(
                    .system(
                        size: 12,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    badgeForeground
                )
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(badgeBackground)
                .overlay {
                    Capsule()
                        .stroke(
                            summaryBorder,
                            lineWidth: 1
                        )
                }
                .clipShape(Capsule())

            Spacer()
                .frame(height: 10)

            Text(presentation.title)
                .font(
                    .system(
                        size: 25,
                        weight: .heavy
                    )
                )
                .foregroundStyle(
                    Color("TextPrimary")
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Spacer()
                .frame(height: 5)

            Text(presentation.detail)
                .font(.system(size: 12))
                .foregroundStyle(
                    Color("TextSecondary")
                )
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
        }
        .padding(14)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(summaryBackground)
        .overlay {
            RoundedRectangle(
                cornerRadius: 16
            )
            .stroke(
                summaryBorder,
                lineWidth: 1
            )
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    private var summaryBackground: Color {
        switch presentation.style {

        case .success:
            return Color("SuccessGreenSoft")

        case .warning:
            return Color("WarningAmberSoft")

        case .neutral:
            return Color("SurfacePrimary")
        }
    }

    private var summaryBorder: Color {
        switch presentation.style {

        case .success:
            return Color("SuccessGreenBorder")

        case .warning,
             .neutral:
            return Color("BorderPrimary")
        }
    }

    private var badgeBackground: Color {
        switch presentation.style {

        case .success:
            return Color("SuccessGreenSoft")

        case .warning:
            return Color("WarningAmberSoft")

        case .neutral:
            return Color("NeutralSoft")
        }
    }

    private var badgeForeground: Color {
        switch presentation.style {

        case .success:
            return Color("SuccessGreen")

        case .warning:
            return Color("WarningAmber")

        case .neutral:
            return Color("TextSecondary")
        }
    }
}

#Preview("Linked Demo Donor") {
    NavigationStack {
        DonationReadinessView(
            donorRecordsStore:
                DonorRecordsStore(
                    linkState:
                        .linked(
                            profile:
                                DonorDemoData.profile
                        ),
                    records:
                        DonorDemoData.records
                )
        )
    }
}

#Preview("Unlinked") {
    NavigationStack {
        DonationReadinessView(
            donorRecordsStore:
                DonorRecordsStore()
        )
    }
}
