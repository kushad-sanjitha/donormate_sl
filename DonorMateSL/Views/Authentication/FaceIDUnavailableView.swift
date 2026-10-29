//
//  FaceIDUnavailableView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import SwiftUI

struct FaceIDUnavailableView: View {
    var onBack: () -> Void = {}
    var onContinueWithPassword: () -> Void = {}
    var onTryAgain: () -> Void = {}

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
                    .fill(Color("InfoBlueSoft"))
                    .frame(width: 124, height: 124)
                    .overlay {
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(
                                Color("InfoBlue").opacity(0.18),
                                lineWidth: 1
                            )
                    }

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(Color("InfoBlue"))
            }
            .accessibilityHidden(true)

            Spacer()
                .frame(height: 26)

            VStack(spacing: 10) {

                Text("Face ID isn’t available")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(
                    "You can continue using your account password and enable biometric protection later from Settings."
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

            VStack(spacing: 10) {

                Button {
                    onContinueWithPassword()
                } label: {
                    Text("Continue with Password")
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
                    onTryAgain()
                } label: {
                    Text("Try Face ID Again")
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
    FaceIDUnavailableView(
        onBack: {
            print("Back tapped")
        },
        onContinueWithPassword: {
            print("Continue with password tapped")
        },
        onTryAgain: {
            print("Try Face ID again tapped")
        }
    )
}
