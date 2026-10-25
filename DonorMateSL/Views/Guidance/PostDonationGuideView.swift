//
//  PostDonationGuideView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/25/26.
//

import SwiftUI

struct PostDonationGuideView: View {
    @Environment(\.dismiss) private var dismiss

    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "After Your Donation",
                onBack: { dismiss() }
            )

            ScreenScrollView {
                VStack(spacing: 0) {
                    EmptyStateIllustration(
                        systemImage: "heart.fill",
                        width: 160,
                        height: 112,
                        symbolSize: 46
                    )
                    .padding(.top, 12)
                    .padding(.bottom, 6)
                    .accessibilityHidden(true)

                    VStack(spacing: 8) {
                        Text("Thank you for donating")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))

                        Text("Review the after-care guidance provided for your recovery.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color("TextSecondary"))
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                    LazyVStack(spacing: 10) {
                        ForEach(DonationGuidanceCatalog.postDonationSteps) { step in
                            GuidanceItemRow(
                                text: step.text,
                                style: step.marker == .warning ? .warning : .check
                            )
                        }
                    }
                    .padding(.top, 16)

                    Button(action: onDone) {
                        Text("Done")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color("SurfacePrimary"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color("BorderPrimary"), lineWidth: 1)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 16)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview("Screen 33 - After Your Donation") {
    NavigationStack {
        PostDonationGuideView(onDone: {})
    }
}
