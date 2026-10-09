//
//  HomeView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct HomeView: View {

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

                        DonationCountdownCard(
                            daysRemaining: 24,
                            nextPossibleDate: "18 September 2026",
                            progress: 0.72
                        )

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
