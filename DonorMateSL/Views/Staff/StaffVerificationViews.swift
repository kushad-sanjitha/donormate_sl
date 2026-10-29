//
//  StaffVerificationViews.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import SwiftUI

struct StaffIdentityComparisonView: View {
    let comparison: StaffIdentityComparison
    let onContinue: () -> Void
    let onScanAgain: () -> Void
    let onManualLookup: () -> Void

    private var title: String {
        switch comparison.outcome {
        case .allFieldsAgree: return "Details agree"
        case .addressNeedsReview: return "Address needs review"
        case .nameMismatch: return "Name does not match"
        case .recordNotFound: return "Record not found"
        case .insufficientDetails: return "More details needed"
        }
    }

    private var explanation: String {
        switch comparison.outcome {
        case .allFieldsAgree:
            return "The captured NIC number, name and address agree with the available donor record."
        case .addressNeedsReview:
            return "The NIC number and name agree, but the address is different or wasn't captured. Review the card before proceeding."
        case .nameMismatch:
            return "The NIC number was found, but the captured name does not agree with the record. Manual verification is required."
        case .recordNotFound:
            return "No matching donor record was found for this identity number."
        case .insufficientDetails:
            return "The card's NIC number or name could not be reliably captured. Try scanning again or use manual lookup."
        }
    }

    var body: some View {
        StaffPageHeading(
            eyebrow: "Record comparison",
            title: title,
            subtitle: explanation
        )

        comparisonStatus

        if let record = comparison.record {
            StaffPanel {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Captured details and donor record")
                        .font(.headline)

                    comparisonRow(
                        title: "NIC number",
                        captured: comparison.scanned.nicNumber,
                        recorded: record.nicNumber,
                        agrees: NationalIdentityNumberValidator.validated(comparison.scanned.nicNumber ?? "") == record.nicNumber
                    )
                    Divider()
                    comparisonRow(
                        title: "Name",
                        captured: comparison.scanned.name,
                        recorded: record.name,
                        agrees: comparison.outcome != .nameMismatch && comparison.outcome != .insufficientDetails
                    )
                    Divider()
                    comparisonRow(
                        title: "Address",
                        captured: comparison.scanned.address,
                        recorded: record.address,
                        agrees: comparison.outcome == .allFieldsAgree
                    )
                }
            }
        } else if let nic = comparison.scanned.nicNumber {
            StaffPanel {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Captured NIC number").font(.subheadline.weight(.semibold))
                    Text(nic).font(.body.monospaced())
                }
            }
        }

        StaffNotice(message: "Check the original identity card before continuing. Text recognition and record comparison alone do not verify identity.")

        switch comparison.outcome {
        case .allFieldsAgree:
            StaffActionButton(title: "View Donor Record", action: onContinue)
            StaffActionButton(title: "Scan Another NIC", primary: false, action: onScanAgain)

        case .addressNeedsReview:
            StaffActionButton(title: "Acknowledge Address & View Record", action: onContinue)
            StaffActionButton(title: "Cancel & Rescan", primary: false, action: onScanAgain)

        case .nameMismatch, .recordNotFound, .insufficientDetails:
            StaffActionButton(title: "Scan Again", action: onScanAgain)
            StaffActionButton(title: "Manual NIC Lookup", primary: false, action: onManualLookup)
        }
    }

    private func comparisonRow(
        title: String,
        captured: String?,
        recorded: String,
        agrees: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                Text(title).font(.subheadline.weight(.semibold))
                Spacer()
                rowStatus(title: title, agrees: agrees)
            }
            Text("Captured: \(captured ?? "Not captured")")
                .font(.subheadline)
                .textSelection(.enabled)
            Text("Donor record: \(recorded)")
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
                .textSelection(.enabled)
        }
    }

    private var comparisonStatus: some View {
        let isAgree = comparison.outcome == .allFieldsAgree
        let isMismatch = comparison.outcome == .nameMismatch
        let tint = isAgree ? Color("SuccessGreen") : (isMismatch ? Color("DonorRed") : Color("WarningAmber"))
        let background = isAgree ? Color("SuccessGreenSoft") : (isMismatch ? Color("DonorRedSoft") : Color("WarningAmberSoft"))

        return Label(
            isAgree ? "All fields agree" : (isMismatch ? "Name mismatch" : "Review required"),
            systemImage: isAgree ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
        )
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(tint)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(13)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func rowStatus(title: String, agrees: Bool) -> some View {
        let isMismatch = !agrees && title == "Name" && comparison.outcome == .nameMismatch
        let tint = agrees ? Color("SuccessGreen") : (isMismatch ? Color("DonorRed") : Color("WarningAmber"))
        let background = agrees ? Color("SuccessGreenSoft") : (isMismatch ? Color("DonorRedSoft") : Color("WarningAmberSoft"))

        return Label(
            agrees ? "Agree" : (isMismatch ? "Mismatch" : "Review"),
            systemImage: agrees ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
        )
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(background)
        .clipShape(Capsule())
    }
}

struct StaffManualLookupView: View {
    @Binding var nicNumber: String
    let error: String?
    let onSearch: () -> Void
    let onBack: () -> Void

    var body: some View {
        StaffPageHeading(
            eyebrow: "Identity verification",
            title: "Manual NIC lookup",
            subtitle: "Enter an identity number exactly as printed on the card."
        )

        StaffPanel {
            VStack(alignment: .leading, spacing: 14) {
                StaffFormField(title: "NIC number") {
                    TextField("12 digits or 9 digits and V/X", text: $nicNumber)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                        .accessibilityIdentifier("staff.manualNIC")
                }
                if let error {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(Color("DonorRed"))
                }
            }
        }

        StaffActionButton(title: "Find Donor Record", action: onSearch)
        StaffActionButton(title: "Back", primary: false, action: onBack)
        StaffNotice(message: "Enter the number exactly as shown. Finding a record does not confirm the card belongs to the person presenting it.")
    }
}

struct StaffDonorRecordDetailView: View {
    let record: StaffDonorIdentityRecord
    let reachedByManualLookup: Bool
    let onFinish: () -> Void
    let onScanAnother: () -> Void

    var body: some View {
        StaffPageHeading(
            eyebrow: "Donor records",
            title: "Donor record",
            subtitle: reachedByManualLookup
                ? "Opened using a manual NIC search. No identity comparison was completed."
                : "Opened after staff reviewed an OCR comparison."
        )

        StaffPanel {
            VStack(alignment: .leading, spacing: 13) {
                recordRow("Name", record.profile.displayName)
                Divider()
                recordRow("NIC number", record.nicNumber)
                Divider()
                recordRow("Donor reference", record.profile.donorRecordID ?? "Unavailable")
                Divider()
                recordRow("Blood group", record.profile.bloodGroup)
                Divider()
                recordRow("Recorded history entries", "\(record.donationRecords.count)")
                if let reportedCount = record.profile.reportedDonationCount {
                    Divider()
                    recordRow("Reported donation count", "\(reportedCount)")
                }
            }
        }

        if let latest = record.donationRecords.max(by: { $0.date < $1.date }) {
            StaffPanel {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Latest recorded donation").font(.headline)
                    recordRow("Date", latest.date.formatted(date: .abbreviated, time: .omitted))
                    recordRow("Location", latest.location)
                    recordRow("Type", latest.donationType)
                    recordRow(
                        "Recorded next possible date",
                        latest.nextPossibleDonationDate?.formatted(date: .abbreviated, time: .omitted)
                            ?? "Not available"
                    )
                }
            }
        }

        StaffNotice(message: "This build uses a locally stored test record, not the official donor register. Confirm identity through an authorized source. Donation dates do not establish medical eligibility.")
        StaffActionButton(title: "Finish Review", action: onFinish)
        StaffActionButton(title: "Scan Another Donor", primary: false, action: onScanAnother)
    }

    private func recordRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
            Spacer(minLength: 10)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}

struct StaffRecordNotFoundView: View {
    let onScanAgain: () -> Void
    let onManualLookup: () -> Void

    var body: some View {
        StaffPageHeading(
            eyebrow: "Record comparison",
            title: "Record not found",
            subtitle: "No matching donor record was found for the captured NIC number."
        )
        StaffNotice(message: "Check the NIC number against the original card and consult the official register when needed. No match was confirmed.")
        StaffActionButton(title: "Scan Again", action: onScanAgain)
        StaffActionButton(title: "Manual NIC Lookup", primary: false, action: onManualLookup)
    }
}

struct StaffRecordServiceErrorView: View {
    let onRetry: () -> Void
    let onBack: () -> Void

    var body: some View {
        StaffPageHeading(
            eyebrow: "Record lookup",
            title: "Lookup unavailable",
            subtitle: "The record couldn't be loaded. No match was confirmed."
        )
        StaffActionButton(title: "Try Again", action: onRetry)
        StaffActionButton(title: "Back to Dashboard", primary: false, action: onBack)
    }
}
