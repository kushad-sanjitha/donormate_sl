//
//  DonationReadinessView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct DonationReadinessView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {

                HStack(
                    alignment: .center,
                    spacing: 10
                ) {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .frame(width: 38, height: 38)
                            .background(Color("SurfacePrimary"))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        Color("BorderPrimary"),
                                        lineWidth: 1
                                    )
                            }
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")

                    Text("Donation Readiness")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()
                }
                .frame(minHeight: 46)

                Spacer()
                    .frame(height: 8)

                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    Text("Date check")
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

                    Spacer()
                        .frame(height: 10)

                    Text("Minimum wait completed")
                        .font(.system(size: 25, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Spacer()
                        .frame(height: 5)

                    Text(
                        "Based on your latest recorded donation on 18 May 2026."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextSecondary"))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }
                .padding(14)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(Color("SuccessGreenSoft"))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color("SuccessGreenBorder"),
                            lineWidth: 1
                        )
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

                Spacer()
                    .frame(height: 16)

                Text("Before you donate")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color("TextPrimary"))
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Confirm the current donation requirements.",
                    style: .check
                )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Bring valid identification.",
                    style: .check
                )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Follow official preparation guidance.",
                    style: .check
                )

                Spacer()
                    .frame(height: 10)

                GuidanceItemRow(
                    text: "Final medical eligibility is always confirmed by authorised blood-bank staff.",
                    style: .warning
                )

                Spacer()
                    .frame(height: 16)

                Button {
                    print("Find Nearby Donation tapped")
                } label: {
                    Text("Find Nearby Donation")
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

                Spacer()
                    .frame(height: 28)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        .background(Color("BackgroundPrimary"))
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        DonationReadinessView()
    }
}
