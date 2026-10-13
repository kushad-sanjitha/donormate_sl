//
//  HistoryView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct HistoryView: View {

    private enum HistoryState {
        case populated
        case empty
    }

    @State private var historyState: HistoryState = .populated
    var onConnectDonorRecord: () -> Void = {}

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    switch historyState {

                    case .populated:

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

                    case .empty:

                        Text("Donation History")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )

                        Spacer()
                            .frame(height: 82)

                        EmptyStateIllustration(
                            systemImage: "book.fill"
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )

                        Spacer()
                            .frame(height: 10)

                        Text("No linked donations yet")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundStyle(Color("TextPrimary"))
                            .multilineTextAlignment(.center)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .center
                            )

                        Spacer()
                            .frame(height: 10)

                        Text(
                            "Your donation history will appear here when a blood-bank record is available and connected."
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextSecondary"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )

                        Spacer()
                            .frame(height: 18)

                        InfoMessageCard(
                            systemImage: "cloud.fill",
                            title: "View-only updates",
                            detail: "Donors can view linked records, but cannot create or edit them."
                        )

                        Spacer()
                            .frame(height: 18)

                        Button {
                            onConnectDonorRecord()
                        } label: {
                            Text("Connect Donor Record")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 48
                                )
                                .background(Color("DonorRed"))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 14)
                                )
                        }
                        .buttonStyle(.plain)
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
    HistoryView(
        onConnectDonorRecord: {
            print("Connect Donor Record tapped")
        }
    )
}
