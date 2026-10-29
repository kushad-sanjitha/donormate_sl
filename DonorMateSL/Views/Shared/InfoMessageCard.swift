//
//  InfoMessageCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct InfoMessageCard: View {
    let systemImage: String
        let title: String
        let detail: String

        var body: some View {
            HStack(
                alignment: .top,
                spacing: 12
            ) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("InfoBlueSoft"))
                        .frame(width: 40, height: 40)

                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color("InfoBlue"))
                }
                .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(detail)
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
        }
    }

    #Preview {
        VStack(spacing: 14) {

            InfoMessageCard(
                systemImage: "cloud.fill",
                title: "Records are added by the blood bank",
                detail: "You can view your history here. Donors cannot add or change donation records."
            )

            InfoMessageCard(
                systemImage: "eye.fill",
                title: "View-only updates",
                detail: "Donors can view linked records, but cannot create or edit them."
            )
        }
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
