//
//  HistoryView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {

                        HStack(
                            alignment: .top,
                            spacing: 12
                        ) {

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text("Your donation records")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color("TextSecondary"))

                                Text("Donation History")
                                    .font(.system(size: 24, weight: .heavy))
                                    .foregroundStyle(Color("TextPrimary"))
                            }

                            Spacer()

                            Text("Up to date")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color("SuccessGreen"))
                                .padding(.horizontal, 10)
                                .frame(height: 28)
                                .background(Color("SuccessGreenSoft"))
                                .overlay {
                                    Capsule()
                                        .stroke(
                                            Color("SuccessGreenBorder"),
                                            lineWidth: 1
                                        )
                                }
                                .clipShape(Capsule())
                        }

                        Spacer()
                            .frame(height: 8)

                        HStack(
                            alignment: .top,
                            spacing: 12
                        ) {

                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("InfoBlueSoft"))
                                    .frame(width: 40, height: 40)

                                Image(systemName: "cloud.fill")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color("InfoBlue"))
                            }
                            .accessibilityHidden(true)

                            VStack(
                                alignment: .leading,
                                spacing: 4
                            ) {

                                Text("Records are added by the blood bank")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(Color("TextPrimary"))
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )

                                Text(
                                    "You can view your history here. Donors cannot add or change donation records."
                                )
                                .font(.system(size: 12))
                                .foregroundStyle(Color("TextSecondary"))
                                .lineSpacing(3)
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
                        .background(Color("InfoBlueSoft"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    Color("InfoBlueBorder"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )

                        Spacer()
                            .frame(height: 14)

                        HStack(
                            alignment: .top,
                            spacing: 10
                        ) {

                            SummaryMetricCard(
                                title: "Total donations",
                                value: "6",
                                detail: "Linked record"
                            )

                            SummaryMetricCard(
                                title: "Latest donation",
                                value: "18 May",
                                detail: "2026"
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
        HistoryView()
    }
