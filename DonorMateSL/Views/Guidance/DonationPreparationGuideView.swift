//
//  DonationPreparationGuideView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import SwiftUI

struct DonationPreparationGuideView: View {
    @Environment(\.dismiss) private var dismiss

    let onFindNearby: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Before You Donate",
                onBack: { dismiss() }
            )

            ScreenScrollView {
                VStack(spacing: 0) {
                    InfoMessageCard(
                        systemImage: "info.circle.fill",
                        title: "Quick preparation guide",
                        detail: "Use official guidance and confirm requirements with the blood bank."
                    )
                    .padding(.bottom, 14)

                    LazyVStack(spacing: 10) {
                        ForEach(DonationGuidanceCatalog.preparationSteps) { step in
                            GuidanceItemRow(
                                text: step.text,
                                style: rowStyle(for: step.marker)
                            )
                        }
                    }

                    Button(action: onFindNearby) {
                        Text("Find Nearby Donation")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("DonorRed"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
    }

    private func rowStyle(for marker: DonationGuidanceStep.Marker) -> GuidanceItemRow.Style {
        switch marker {
        case .number(let number):
            .number(String(number))
        case .check:
            .check
        case .warning:
            .warning
        }
    }
}

#Preview("Screen 32 - Before You Donate") {
    NavigationStack {
        DonationPreparationGuideView(onFindNearby: {})
    }
}
