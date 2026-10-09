//
//  HomeView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct HomeView: View {

    private enum HomeState {
            case notReady
            case ready
            case urgent
        }

        @State private var homeState: HomeState = .urgent

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {

                        HStack(alignment: .center) {

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text("Good morning")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color("TextSecondary"))

                                Text("Hi, Kushad")
                                    .font(.system(size: 20, weight: .heavy))
                                    .foregroundStyle(Color("TextPrimary"))
                            }

                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(Color("DonorRedSoft"))
                                    .frame(width: 40, height: 40)

                                Text("KD")
                                    .font(.system(size: 13, weight: .heavy))
                                    .foregroundStyle(Color("DonorRed"))
                            }
                        }

                        Spacer()
                            .frame(height: 16)

                        switch homeState {
                        case .notReady:
                            DonationCountdownCard(
                                daysRemaining: 24,
                                nextPossibleDate: "18 September 2026",
                                progress: 0.72
                            )

                        case .ready:
                            HomeReadyCard(
                                onFindOpportunity: {
                                    print("Find opportunity tapped")
                                }
                            )

                        case .urgent:
                            HomeUrgentCard(
                                matchText: "A+ match",
                                title: "A+ blood urgently needed nearby",
                                detail: "Matara Blood Bank · 2.8 km",
                                onViewAlert: {
                                    print("View alert tapped")
                                },
                                onSave: {
                                    print("Save tapped")
                                }
                            )
                        }

                        switch homeState {
                        case .notReady, .ready:

                            Spacer()
                                .frame(height: 14)

                            HStack(
                                alignment: .top,
                                spacing: 10
                            ) {

                                HomeMetricCard(
                                    title: "Last donation",
                                    value: "18 May",
                                    detail: "Matara"
                                )

                                HomeMetricCard(
                                    title: "Recorded donations",
                                    value: "6",
                                    detail: "Blood-bank records"
                                )
                            }

                        case .urgent:
                            EmptyView()
                        }

                        switch homeState {

                        case .notReady:

                            Spacer()
                                .frame(height: 16)

                            HStack(alignment: .center) {

                                Text("Nearby this week")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color("TextPrimary"))

                                Spacer()

                                Button {
                                    print("See all tapped")
                                } label: {
                                    Text("See all")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color("DonorRed"))
                                }
                                .buttonStyle(.plain)
                            }

                            Spacer()
                                .frame(height: 8)

                            HomeOpportunityRow(
                                title: "Matara Donation Camp",
                                detail: "Sat · 9:00 AM · 2.4 km"
                            )

                            Spacer()
                                .frame(height: 16)

                            Text("Quick actions")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color("TextPrimary"))
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )

                            Spacer()
                                .frame(height: 8)

                            HStack(
                                alignment: .top,
                                spacing: 10
                            ) {

                                HomeQuickActionCard(
                                    title: "View Readiness",
                                    systemImage: "checkmark.circle.fill",
                                    iconBackground: Color("SuccessGreenSoft"),
                                    iconForeground: Color("SuccessGreen")
                                )

                                HomeQuickActionCard(
                                    title: "Find Nearby",
                                    systemImage: "map.fill",
                                    iconBackground: Color("InfoBlueSoft"),
                                    iconForeground: Color("InfoBlue")
                                )
                            }

                        case .ready:

                            Spacer()
                                .frame(height: 16)

                            HStack(alignment: .center) {

                                Text("Closest opportunity")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color("TextPrimary"))

                                Spacer()

                                Button {
                                    print("View map tapped")
                                } label: {
                                    Text("View map")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(Color("DonorRed"))
                                }
                                .buttonStyle(.plain)
                            }

                            Spacer()
                                .frame(height: 8)

                            HomeOpportunityRow(
                                title: "Matara Blood Bank",
                                detail: "Open today · 2.1 km"
                            )

                            Spacer()
                                .frame(height: 14)

                            HStack(
                                alignment: .top,
                                spacing: 10
                            ) {

                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("NeutralSoft"))
                                        .frame(width: 34, height: 34)

                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(Color("TextSecondary"))
                                }
                                .accessibilityHidden(true)

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text("Final eligibility is confirmed by staff.")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Color("TextPrimary"))
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )

                                    Text(
                                        "DonorMate only tracks the recorded waiting period."
                                    )
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color("TextSecondary"))
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            }
                            .padding(14)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(Color("SurfaceSecondary"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        Color("BorderPrimary"),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )

                        case .urgent:

                            Spacer()
                                .frame(height: 14)

                            HStack(
                                alignment: .top,
                                spacing: 10
                            ) {

                                ZStack {
                                    Circle()
                                        .fill(Color("SuccessGreenSoft"))
                                        .frame(width: 22, height: 22)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Color("SuccessGreen"))
                                }
                                .accessibilityHidden(true)

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {

                                    Text("Your waiting period has passed")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(Color("TextPrimary"))
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )

                                    Text("Normal donor screening still applies.")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color("TextSecondary"))
                                        .fixedSize(
                                            horizontal: false,
                                            vertical: true
                                        )
                                }
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            }
                            .padding(14)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                            .background(Color("SuccessGreenSoft"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        Color("SuccessGreenBorder"),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )

                            Spacer()
                                .frame(height: 16)

                            Text("Today")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(Color("TextPrimary"))
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )

                            Spacer()
                                .frame(height: 8)

                            HomeOpportunityRow(
                                title: "Matara Donation Camp",
                                detail: "9:00 AM – 3:00 PM · 2.4 km"
                            )
                        }

                        Spacer()
                            .frame(height: 28)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                }
                .background(Color("BackgroundPrimary"))
            }
        }
    }

    #Preview {
        HomeView()
    }
