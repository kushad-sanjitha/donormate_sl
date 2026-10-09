//
//  HomeMetricCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/8/26.
//

import SwiftUI

struct HomeMetricCard: View {
    let title: String
        let value: String
        let detail: String

        var body: some View {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                Text(title)
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))

                Spacer()
                    .frame(height: 4)

                Text(value)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color("TextPrimary"))

                Spacer()
                    .frame(height: 4)

                Text(detail)
                    .font(.system(size: 11))
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
            .padding(12)
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
        }
    }

    #Preview {
        HomeMetricCard(
            title: "Last donation",
            value: "18 May",
            detail: "Matara"
        )
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
