//
//  FaceIDSetupView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import SwiftUI

struct FaceIDSetupView: View {
    var onBack: () -> Void = {}
        var onEnableFaceID: () -> Void = {}
        var onNotNow: () -> Void = {}

        var body: some View {
            VStack(spacing: 0) {

                HStack {

                    Button {
                        onBack()
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
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back")

                    Spacer()

                    Text("Face ID")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }

                Spacer()
                    .frame(height: 40)

                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color("NeutralSoft"))
                        .frame(width: 116, height: 116)
                        .overlay {
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(
                                    Color("BorderPrimary"),
                                    lineWidth: 1
                                )
                        }

                    Image(systemName: "faceid")
                        .font(.system(size: 52, weight: .medium))
                        .foregroundStyle(Color("TextPrimary"))
                }
                .accessibilityHidden(true)

                Spacer()
                    .frame(height: 26)

                VStack(spacing: 10) {

                    Text("Protect DonorMate with Face ID")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))
                        .multilineTextAlignment(.center)
                        .fixedSize(
                            horizontal: false,
                            vertical: true
                        )

                    Text(
                        "Use Face ID for quick access after you have signed in."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )
                }
                .padding(.horizontal, 12)

                Spacer()
                    .frame(height: 24)

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("SuccessGreenSoft"))
                            .frame(width: 36, height: 36)

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color("SuccessGreen"))
                    }
                    .accessibilityHidden(true)

                    Text(
                        "Biometric information remains managed by iOS. DonorMate only receives the authentication result."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextPrimary"))
                    .lineSpacing(2)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                    Spacer(minLength: 0)
                }
                .padding(14)
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

                Spacer()

                VStack(spacing: 10) {

                    Button {
                        onEnableFaceID()
                    } label: {
                        Text("Enable Face ID")
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
                        onNotNow()
                    } label: {
                        Text("Not Now")
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
                .padding(.bottom, 26)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(Color("BackgroundPrimary"))
        }
    }

    #Preview {
        FaceIDSetupView(
            onBack: {
                print("Back tapped")
            },
            onEnableFaceID: {
                print("Enable Face ID tapped")
            },
            onNotNow: {
                print("Face ID skipped")
            }
        )
    }
