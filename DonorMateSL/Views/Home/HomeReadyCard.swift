//
//  HomeReadyCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/9/26.
//

import SwiftUI

struct HomeReadyCard: View {
    var onFindOpportunity: () -> Void = {}

        var body: some View {
            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                Text("Ready")
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

                Text("Minimum waiting period completed")
                    .font(.system(size: 27, weight: .heavy))
                    .foregroundStyle(Color("TextPrimary"))
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Spacer()
                    .frame(height: 6)

                Text(
                    "Based on your latest recorded donation date."
                )
                .font(.system(size: 14))
                .foregroundStyle(Color("TextSecondary"))
                .lineSpacing(3)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

                Spacer()
                    .frame(height: 12)

                Button {
                    onFindOpportunity()
                } label: {
                    Text("Find a Donation Opportunity")
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
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 3
            )
        }
    }

    #Preview {
        HomeReadyCard(
            onFindOpportunity: {
                print("Find opportunity tapped")
            }
        )
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
