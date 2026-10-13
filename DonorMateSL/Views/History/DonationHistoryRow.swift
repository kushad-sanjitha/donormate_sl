//
//  DonationHistoryRow.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct DonationHistoryRow: View {
    let record: DonationRecord
        let isLast: Bool

        var body: some View {
            ZStack(
                alignment: .topLeading
            ) {

                if !isLast {
                    Rectangle()
                        .fill(Color("BorderPrimary"))
                        .frame(width: 2)
                        .frame(
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .offset(x: 6)
                }

                HStack(
                    alignment: .top,
                    spacing: 0
                ) {

                    ZStack {
                        Circle()
                            .fill(Color("DonorRedSoft"))
                            .frame(width: 14, height: 14)

                        Circle()
                            .fill(Color("DonorRed"))
                            .frame(width: 8, height: 8)
                    }
                    .frame(
                        width: 22,
                        alignment: .leading
                    )
                    .accessibilityHidden(true)

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(record.date)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))

                        Text(record.locationAndType)
                            .font(.system(size: 12))
                            .foregroundStyle(Color("TextSecondary"))
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        Text(record.recordLabel)
                            .font(.system(size: 11))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                }
                .padding(
                    .bottom,
                    isLast ? 0 : 18
                )
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    #Preview {
        VStack(spacing: 0) {

            DonationHistoryRow(
                record: DonationRecord(
                    date: "18 May 2026",
                    location: "Matara Blood Bank",
                    donationType: "Whole blood",
                    recordLabel: "Blood-bank record",
                    recordReference: "DB-2026-0518-006",
                    nextPossibleDonationDate: "18 September 2026"
                ),
                isLast: false
            )

            DonationHistoryRow(
                record: DonationRecord(
                    date: "16 January 2026",
                    location: "Matara",
                    donationType: "Whole blood",
                    recordLabel: "Blood-bank record",
                    recordReference: nil,
                    nextPossibleDonationDate: nil
                ),
                isLast: true
            )
        }
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
