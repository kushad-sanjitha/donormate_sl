//
//  DetailInfoRow.swift
//  DonorMateSL
//
//  Created by user300742 on 10/13/26.
//

import SwiftUI

struct DetailInfoRow: View {
    let systemImage: String
        let label: String
        let value: String
        let supportingText: String?

        init(
            systemImage: String,
            label: String,
            value: String,
            supportingText: String? = nil
        ) {
            self.systemImage = systemImage
            self.label = label
            self.value = value
            self.supportingText = supportingText
        }

        var body: some View {
            HStack(
                alignment: .center,
                spacing: 12
            ) {

                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("NeutralSoft"))
                        .frame(width: 40, height: 40)

                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color("TextSecondary"))
                }
                .accessibilityHidden(true)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(label)
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextSecondary"))

                    Text(value)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    if let supportingText {
                        Text(supportingText)
                            .font(.system(size: 11))
                            .foregroundStyle(Color("TextSecondary"))
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )
                    }
                }

                Spacer()
            }
            .padding(12)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(Color("SurfacePrimary"))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        Color("BorderPrimary"),
                        lineWidth: 1
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
        }
    }

    #Preview {
        VStack(spacing: 10) {

            DetailInfoRow(
                systemImage: "location.fill",
                label: "Location",
                value: "Matara Blood Bank"
            )

            DetailInfoRow(
                systemImage: "building.2.fill",
                label: "Recorded by",
                value: "Blood-bank staff"
            )

            DetailInfoRow(
                systemImage: "number.square.fill",
                label: "Record reference",
                value: "DB-2026-0518-006",
                supportingText: "Example supporting information"
            )
        }
        .padding(18)
        .background(Color("BackgroundPrimary"))
    }
