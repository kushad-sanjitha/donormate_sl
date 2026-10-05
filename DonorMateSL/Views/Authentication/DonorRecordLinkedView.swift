//
//  DonorRecordLinkedView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import SwiftUI

struct DonorRecordLinkedView: View {
    let name: String
        let bloodGroup: String
        let donationCount: Int

        var onContinue: () -> Void = {}

        private var initials: String {
            let parts = name
                .split(separator: " ")
                .prefix(2)

            return parts
                .compactMap { $0.first }
                .map(String.init)
                .joined()
                .uppercased()
        }

        var body: some View {
            VStack(spacing: 0) {

                Spacer()
                    .frame(height: 44)

                ZStack {
                    Circle()
                        .fill(Color("SuccessGreenSoft"))
                        .frame(width: 84, height: 84)

                    Image(systemName: "checkmark")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color("SuccessGreen"))
                }
                .accessibilityHidden(true)

                Spacer()
                    .frame(height: 20)

                VStack(spacing: 10) {

                    Text("Donor record connected")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))
                        .multilineTextAlignment(.center)

                    Text(
                        "We found the donor-linked information associated with the details you provided."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                }
                .padding(.horizontal, 8)

                Spacer()
                    .frame(height: 24)

                HStack(
                    alignment: .center,
                    spacing: 12
                ) {

                    ZStack {
                        Circle()
                            .fill(Color("DonorRedSoft"))
                            .frame(width: 54, height: 54)

                        Text(initials)
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(Color("DonorRed"))
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color("TextPrimary"))
                            .multilineTextAlignment(.leading)
                            .fixedSize(
                                horizontal: false,
                                vertical: true
                            )

                        Text("Blood group · \(bloodGroup)")
                            .font(.system(size: 13))
                            .foregroundStyle(Color("TextSecondary"))

                        Text(
                            "\(donationCount) recorded donation\(donationCount == 1 ? "" : "s")"
                        )
                        .font(.system(size: 12))
                        .foregroundStyle(Color("TextSecondary"))
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    Spacer(minLength: 0)
                }
                .padding(16)
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
                .shadow(
                    color: .black.opacity(0.04),
                    radius: 8,
                    x: 0,
                    y: 3
                )

                Spacer()
                    .frame(height: 14)

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                Color("InfoBlue")
                                    .opacity(0.10)
                            )
                            .frame(
                                width: 36,
                                height: 36
                            )

                        Image(systemName: "info.circle.fill")
                            .font(
                                .system(
                                    size: 18,
                                    weight: .semibold
                                )
                            )
                            .foregroundStyle(Color("InfoBlue"))
                    }
                    .accessibilityHidden(true)

                    Text(
                        "Donation records are supplied by the linked service and cannot be changed by you in DonorMate."
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(Color("TextPrimary"))
                    .lineSpacing(2)

                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(Color("InfoBlueSoft"))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            Color("InfoBlue").opacity(0.18),
                            lineWidth: 1
                        )
                }
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Continue")
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
        DonorRecordLinkedView(
            name: "Sample Donor With A Longer Name",
            bloodGroup: "A+",
            donationCount: 6,
            onContinue: {
                print("Continue tapped")
            }
        )
    }
