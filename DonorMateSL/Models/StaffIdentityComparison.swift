//
//  StaffIdentityComparison.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import Foundation

nonisolated struct StaffIdentityFields: Equatable, Sendable {
    let nicNumber: String?
    let name: String?
    let address: String?

    init(result: StaffScanResult) {
        func value(for label: String) -> String? {
            let prefix = "\(label):"
            return result.lines.first { $0.text.lowercased().hasPrefix(prefix.lowercased()) }
                .map { String($0.text.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines) }
                .flatMap { $0.isEmpty ? nil : $0 }
        }

        nicNumber = value(for: "NIC number")
        name = value(for: "Name")
        address = value(for: "Address")
    }

    init(nicNumber: String?, name: String?, address: String?) {
        self.nicNumber = nicNumber
        self.name = name
        self.address = address
    }
}

nonisolated struct StaffDonorIdentityRecord: Sendable {
    let nicNumber: String
    let name: String
    let address: String
    let profile: DonorProfile
    let donationRecords: [DonationRecord]
}

nonisolated enum StaffComparisonOutcome: Equatable, Sendable {
    case allFieldsAgree
    case addressNeedsReview
    case nameMismatch
    case recordNotFound
    case insufficientDetails
}

nonisolated struct StaffIdentityComparison: Sendable {
    let scanned: StaffIdentityFields
    let record: StaffDonorIdentityRecord?
    let outcome: StaffComparisonOutcome

    var canOpenRecord: Bool {
        record != nil && (outcome == .allFieldsAgree || outcome == .addressNeedsReview)
    }

    static func evaluate(
        scanned: StaffIdentityFields,
        record: StaffDonorIdentityRecord?
    ) -> StaffIdentityComparison {
        guard let capturedNIC = scanned.nicNumber,
              let validatedNIC = NationalIdentityNumberValidator.validated(capturedNIC) else {
            return .init(scanned: scanned, record: nil, outcome: .insufficientDetails)
        }

        guard let record,
              let recordNIC = NationalIdentityNumberValidator.validated(record.nicNumber),
              validatedNIC == recordNIC else {
            return .init(scanned: scanned, record: nil, outcome: .recordNotFound)
        }

        guard let name = scanned.name, !name.isEmpty else {
            return .init(scanned: scanned, record: record, outcome: .insufficientDetails)
        }

        guard normalizedWords(name) == normalizedWords(record.name) else {
            return .init(scanned: scanned, record: record, outcome: .nameMismatch)
        }

        guard let address = scanned.address,
              normalizedWords(address) == normalizedWords(record.address) else {
            return .init(scanned: scanned, record: record, outcome: .addressNeedsReview)
        }

        return .init(scanned: scanned, record: record, outcome: .allFieldsAgree)
    }

    private static func normalizedWords(_ text: String) -> String {
        text.split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .uppercased()
    }
}
