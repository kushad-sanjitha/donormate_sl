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

                        InfoMessageCard(
                            systemImage: "cloud.fill",
                            title: "Records are added by the blood bank",
                            detail: "You can view your history here. Donors cannot add or change donation records."
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
                            .frame(height: 16)

                        VStack(spacing: 0) {

                            DonationHistoryRow(
                                date: "18 May 2026",
                                locationAndType: "Matara Blood Bank · Whole blood",
                                recordLabel: "Blood-bank record",
                                isLast: false
                            )

                            DonationHistoryRow(
                                date: "16 January 2026",
                                locationAndType: "Matara · Whole blood",
                                recordLabel: "Blood-bank record",
                                isLast: false
                            )

                            DonationHistoryRow(
                                date: "12 September 2025",
                                locationAndType: "Matara · Whole blood",
                                recordLabel: "Blood-bank record",
                                isLast: false
                            )

                            DonationHistoryRow(
                                date: "06 May 2025",
                                locationAndType: "Matara · Whole blood",
                                recordLabel: "Blood-bank record",
                                isLast: true
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
