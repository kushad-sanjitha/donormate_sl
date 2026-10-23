//
//  ConnectDonorRecordView.swift
//  DonorMateSL
//
//  Created by user300742 on 10/5/26.
//

import SwiftUI

struct ConnectDonorRecordView: View {

    @State private var donorRecordID = ""
    @State private var lookupErrorMessage: String?
    @State private var isFindingRecord = false

    let maskedNationalIdentityNumber: String

    var onBack: () -> Void = {}

    var onFindRecord:
        (String) async -> Bool =
            { _ in false }

    var onLinkLater: () -> Void = {}
    var onNeedHelp: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            ScreenNavigationHeader(
                title: "Connect Donor Record",
                isBackDisabled: isFindingRecord,
                onBack: {
                    onBack()
                }
            )

            ScrollView {
                VStack(spacing: 0) {

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
                        "Your DonorMate account identity is used for donor-record verification. Enter the donor record reference issued by the blood service."
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

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("Account identity")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color("TextPrimary"))

                    HStack(spacing: 10) {

                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("InfoBlue"))
                            .accessibilityHidden(true)

                        VStack(
                            alignment: .leading,
                            spacing: 2
                        ) {
                            Text("NIC linked to this account")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color("TextPrimary"))

                            Text(maskedNationalIdentityNumber)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color("TextSecondary"))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .frame(minHeight: 58)
                    .background(Color("InfoBlueSoft"))
                    .overlay {
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(
                                Color("InfoBlue").opacity(0.18),
                                lineWidth: 1
                            )
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 13)
                    )
                }

                Spacer()
                    .frame(height: 16)

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("Donor record reference")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color("TextPrimary"))

                    TextField(
                        "e.g. DM-248013",
                        text: $donorRecordID
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("TextPrimary"))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .disabled(isFindingRecord)
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
                    .onSubmit {
                        submitLookup()
                    }
                }

                if let lookupErrorMessage {
                    Text(lookupErrorMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(Color("DonorRed"))
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.top, 10)
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
                        "Blood group and donation history are read-only in DonorMate. Until an authorised donor-record service is connected, record matching uses sample data."
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
                        submitLookup()
                    } label: {
                        Group {
                            if isFindingRecord {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Find My Donor Record")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
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
                    .disabled(isFindingRecord)

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
                    .disabled(isFindingRecord)

                    Button {
                        onNeedHelp()
                    } label: {
                        Text("Having trouble finding your record?")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color("DonorRed"))
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .disabled(isFindingRecord)
                }

                Spacer()
                    .frame(height: 26)
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)
        }
        }
        .background(Color("BackgroundPrimary"))
    }

    private func submitLookup() {

        guard !isFindingRecord else {
            return
        }

        let cleanedRecordID =
            donorRecordID
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .uppercased()

        guard !cleanedRecordID.isEmpty else {
            lookupErrorMessage =
                "Enter your donor record reference."
            return
        }

        lookupErrorMessage = nil
        isFindingRecord = true

        Task {
            let succeeded =
                await onFindRecord(
                    cleanedRecordID
                )

            isFindingRecord = false

            if !succeeded {
                lookupErrorMessage =
                    "No matching sample donor record was found for that reference."
            }
        }
    }
}

#Preview {
    ConnectDonorRecordView(
        maskedNationalIdentityNumber:
            "••••••••5678",
        onBack: {
            print("Back tapped")
        },
        onFindRecord: {
            donorRecordID in

            print(
                "Find record tapped: \(donorRecordID)"
            )

            return true
        },
        onLinkLater: {
            print("Link later tapped")
        },
        onNeedHelp: {
            print("Need help tapped")
        }
    )
}
