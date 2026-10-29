//
//  EmptyStateIllustration.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct EmptyStateIllustration: View {

    let systemImage: String
        let width: CGFloat
        let height: CGFloat
        let symbolSize: CGFloat

        init(
            systemImage: String,
            width: CGFloat = 160,
            height: CGFloat = 120,
            symbolSize: CGFloat = 50
        ) {
            self.systemImage = systemImage
            self.width = width
            self.height = height
            self.symbolSize = symbolSize
        }

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [
                        Color("DonorRedSoft"),
                        Color("SurfacePrimary")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: systemImage)
                    .font(
                        .system(
                            size: symbolSize,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Color("DonorRed"))
                    .accessibilityHidden(true)
            }
            .frame(
                width: width,
                height: height
            )
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        Color("DonorRedBorder"),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 24)
            )
        }
    }

    #Preview {
        VStack(spacing: 20) {

            EmptyStateIllustration(
                systemImage: "book.fill"
            )

            EmptyStateIllustration(
                systemImage: "location.slash.fill",
                width: 150,
                height: 110,
                symbolSize: 44
            )
        }
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
