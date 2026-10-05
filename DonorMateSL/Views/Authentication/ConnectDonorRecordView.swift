//
//  ConnectDonorRecordView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import SwiftUI

struct ConnectDonorRecordView: View {
    @State private var nicNumber = ""
    @State private var donorReference = ""

    var onBack: () -> Void = {}
    var onFindRecord: () -> Void = {}
    var onLinkLater: () -> Void = {}
    var onNeedHelp: () -> Void = {}

    var body: some View {
        ScrollView {
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

                    Text("Connect Donor Record")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color("TextPrimary"))

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }

                Spacer()
                    .frame(height: 18)

                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    Text("LINK YOUR HISTORY")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color("DonorRed"))

                    Text("Connect your existing donor record.")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color("TextPrimary"))
                        .padding(.top, 10)

                    Text(
                        "Enter the details requested by the service to find your existing blood-bank record. DonorMate does not create donation records."
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextSecondary"))
                    .lineSpacing(3)
                    .padding(.top, 10)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                Spacer()
                    .frame(height: 24)

                VStack(spacing: 16) {

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        Text("NIC number")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("TextPrimary"))

                        TextField(
                            "Enter your NIC number",
                            text: $nicNumber
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextPrimary"))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color("SurfacePrimary"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(
                                    Color("BorderPrimary"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 13)
                        )
                    }

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        Text("Donor record reference")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("TextPrimary"))

                        TextField(
                            "e.g. DM-248013",
                            text: $donorReference
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color("TextPrimary"))
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .submitLabel(.done)
                        .padding(.horizontal, 14)
                        .frame(height: 52)
                        .background(Color("SurfacePrimary"))
                        .overlay {
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(
                                    Color("BorderPrimary"),
                                    lineWidth: 1
                                )
                        }
                        .clipShape(
                            RoundedRectangle(cornerRadius: 13)
                        )
                    }
                }

                Spacer()
                    .frame(height: 18)

                HStack(
                    alignment: .top,
                    spacing: 10
                ) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("InfoBlue").opacity(0.10))
                            .frame(width: 36, height: 36)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("InfoBlue"))
                    }
                    .accessibilityHidden(true)

                    Text(
                        "Your linked blood group and donation history will be view-only in DonorMate."
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
                    .frame(height: 18)

                VStack(spacing: 10) {

                    Button {
                        onFindRecord()
                    } label: {
                        Text("Find My Donor Record")
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
                        onLinkLater()
                    } label: {
                        Text("I’ll Link It Later")
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

                    Button {
                        onNeedHelp()
                    } label: {
                        Text("Having trouble finding your record?")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color("DonorRed"))
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                    .frame(height: 26)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        .background(Color("BackgroundPrimary"))
    }
}

#Preview {
    ConnectDonorRecordView(
        onBack: {
            print("Back tapped")
        },
        onFindRecord: {
            print("Find record tapped")
        },
        onLinkLater: {
            print("Link later tapped")
        },
        onNeedHelp: {
            print("Need help tapped")
        }
    )
}
