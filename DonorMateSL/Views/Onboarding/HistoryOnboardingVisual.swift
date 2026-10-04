//
//  HistoryOnboardingVisual.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct HistoryOnboardingVisual: View {
    var body: some View {
            ZStack {

                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("DonorRedSoft"),
                                Color("SurfacePrimary")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                Color("DonorRedBorder"),
                                lineWidth: 1
                            )
                    }

                Image(systemName: "drop.fill")
                    .font(
                        .system(
                            size: 82,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(Color("DonorRed"))
                    .accessibilityHidden(true)
            }
            .frame(
                width: 236,
                height: 205
            )
        }
    }

    #Preview {
        HistoryOnboardingVisual()
    }
