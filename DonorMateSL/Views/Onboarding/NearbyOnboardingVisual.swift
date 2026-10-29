//
//  NearbyOnboardingVisual.swift
//  DonorMateSL
//
//  Created by user300742 on 10/4/26.
//

import SwiftUI

struct NearbyOnboardingVisual: View {
    var body: some View {
            GeometryReader { geometry in

                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {

                    LinearGradient(
                        colors: [
                            Color("NeutralSoft"),
                            Color("SurfacePrimary"),
                            Color("NeutralSoft").opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.green.opacity(0.07))
                        .frame(
                            width: width * 0.33,
                            height: height * 0.32
                        )
                        .position(
                            x: width * 0.18,
                            y: height * 0.18
                        )

                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.green.opacity(0.06))
                        .frame(
                            width: width * 0.38,
                            height: height * 0.35
                        )
                        .position(
                            x: width * 0.80,
                            y: height * 0.76
                        )

                    Capsule()
                        .fill(Color("SurfacePrimary"))
                        .frame(
                            width: width * 0.72,
                            height: 7
                        )
                        .rotationEffect(.degrees(17))
                        .position(
                            x: width * 0.42,
                            y: height * 0.31
                        )

                    Capsule()
                        .fill(Color("SurfacePrimary"))
                        .frame(
                            width: width * 0.70,
                            height: 7
                        )
                        .rotationEffect(.degrees(-18))
                        .position(
                            x: width * 0.63,
                            y: height * 0.62
                        )

                    Capsule()
                        .fill(Color("SurfacePrimary"))
                        .frame(
                            width: width * 0.48,
                            height: 6
                        )
                        .rotationEffect(.degrees(8))
                        .position(
                            x: width * 0.30,
                            y: height * 0.82
                        )

                    mapPin(
                        color: Color("DonorRed")
                    )
                    .position(
                        x: width * 0.30,
                        y: height * 0.34
                    )

                    mapPin(
                        color: Color("InfoBlue")
                    )
                    .position(
                        x: width * 0.77,
                        y: height * 0.65
                    )

                    ZStack {

                        Circle()
                            .fill(
                                Color("InfoBlue")
                                    .opacity(0.18)
                            )
                            .frame(
                                width: 30,
                                height: 30
                            )

                        Circle()
                            .fill(Color("InfoBlue"))
                            .frame(
                                width: 18,
                                height: 18
                            )
                            .overlay {
                                Circle()
                                    .stroke(
                                        Color("SurfacePrimary"),
                                        lineWidth: 4
                                    )
                            }
                    }
                    .position(
                        x: width * 0.52,
                        y: height * 0.49
                    )
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            Color("NeutralBorderStrong"),
                            lineWidth: 1
                        )
                }
            }
            .frame(height: 245)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "Illustration showing nearby donation locations around your current position"
            )
        }

        private func mapPin(color: Color) -> some View {
            ZStack {

                Circle()
                    .fill(Color("SurfacePrimary"))
                    .frame(
                        width: 38,
                        height: 38
                    )
                    .shadow(
                        color: .black.opacity(0.10),
                        radius: 5,
                        x: 0,
                        y: 3
                    )

                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(color)
            }
            .accessibilityHidden(true)
        }
    }

    #Preview {
        NearbyOnboardingVisual()
            .padding()
    }
