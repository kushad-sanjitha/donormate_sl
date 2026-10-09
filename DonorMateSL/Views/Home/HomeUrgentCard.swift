//
//  HomeUrgentCard.swift
//  DonorMateSL
//
//  Created by user300742 on 10/9/26.
//

import SwiftUI

struct HomeUrgentCard: View {
    let matchText: String
    let title: String
    let detail: String
    let onViewAlert: () -> Void
    let onSave: () -> Void

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            HStack(alignment: .center) {

                Text("Urgent")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color("DonorRed"))
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(Color("DonorRedSoft"))
                    .overlay {
                        Capsule()
                            .stroke(
                                Color("DonorRedBorder"),
                                lineWidth: 1
                            )
                    }
                    .clipShape(Capsule())

                Spacer()

                Text(matchText)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color("TextSecondary"))
            }

            Spacer()
                .frame(height: 10)

            Text(title)
                .font(.system(size: 24, weight: .heavy))
                .foregroundStyle(Color("TextPrimary"))
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Spacer()
                .frame(height: 6)

            Text(detail)
                .font(.system(size: 13))
                .foregroundStyle(Color("TextSecondary"))
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )

            Spacer()
                .frame(height: 12)

            HStack(spacing: 10) {

                Button {
                    onViewAlert()
                } label: {
                    Text("View Alert")
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

                Button {
                    onSave()
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 48
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
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(Color("DonorRedSoft"))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color("DonorRedBorder"),
                    lineWidth: 1
                )
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .shadow(
            color: Color("DonorRed").opacity(0.10),
            radius: 8,
            x: 0,
            y: 3
        )
    }
}

#Preview {
    HomeUrgentCard(
        matchText: "A+ match",
        title: "A+ blood urgently needed nearby",
        detail: "Matara Blood Bank · 2.8 km",
        onViewAlert: {
            print("View alert tapped")
        },
        onSave: {
            print("Save tapped")
        }
    )
    .padding(18)
    .background(Color("BackgroundPrimary"))
}
