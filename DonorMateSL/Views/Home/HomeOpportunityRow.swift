//
//  HomeOpportunityRow.swift
//  DonorMateSL
//
//  Created by user300742 on 10/9/26.
//

import SwiftUI

struct HomeOpportunityRow: View {
    let title: String
        let detail: String

        var body: some View {
            HStack(
                alignment: .center,
                spacing: 12
            ) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("InfoBlueSoft"))
                        .frame(width: 40, height: 40)

                    Image(systemName: "location.fill")
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
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color("TextSecondary"))
                    .accessibilityHidden(true)
            }
            .padding(14)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(Color("SurfacePrimary"))
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
            .contentShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
    }

    #Preview {
        HomeOpportunityRow(
            title: "Matara Donation Camp",
            detail: "Sat · 9:00 AM · 2.4 km"
        )
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
