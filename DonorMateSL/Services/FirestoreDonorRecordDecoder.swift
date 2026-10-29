//
//  FirestoreDonorRecordDecoder.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import FirebaseFirestore
import Foundation

nonisolated enum FirestoreDonorDataError: LocalizedError, Sendable {
    case invalidRecord
    case duplicateNIC

    var errorDescription: String? {
        switch self {
        case .invalidRecord:
            return "The donor record contains incomplete or invalid information."
        case .duplicateNIC:
            return "More than one donor record has this NIC number. Contact an administrator."
        }
    }
}

struct FirestoreDonorRecordPayload {
    let ownerUID: String?
    let recordVerified: Bool
    let record: StaffDonorIdentityRecord
}

@MainActor
enum FirestoreDonorRecordDecoder {
    static func decode(_ snapshot: DocumentSnapshot) throws -> FirestoreDonorRecordPayload {
        guard let fields = snapshot.data() else {
            throw FirestoreDonorDataError.invalidRecord
        }
        return try decode(fields: fields, recordID: snapshot.documentID)
    }


    static func decode(fields: [String: Any], recordID: String) throws -> FirestoreDonorRecordPayload {
        guard !recordID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let nicText = fields["nationalIdentityNumber"] as? String,
              let nic = NationalIdentityNumberValidator.validated(nicText),
              let name = nonempty(fields["displayName"] as? String),
              let address = nonempty(fields["address"] as? String),
              let bloodGroup = nonempty(fields["bloodGroup"] as? String) else {
            throw FirestoreDonorDataError.invalidRecord
        }

        let donationFields: [[String: Any]]
        if let value = fields["donations"] {
            guard let decoded = value as? [[String: Any]] else {
                throw FirestoreDonorDataError.invalidRecord
            }
            donationFields = decoded
        } else {
            donationFields = []
        }
        var donations: [DonationRecord] = []

        for entry in donationFields {
            guard let date = dateValue(entry["date"]),
                  let location = nonempty(entry["location"] as? String),
                  let donationType = nonempty(entry["donationType"] as? String),
                  let recordLabel = nonempty(entry["recordLabel"] as? String) else {
                throw FirestoreDonorDataError.invalidRecord
            }

            donations.append(DonationRecord(
                date: date,
                location: location,
                donationType: donationType,
                recordLabel: recordLabel,
                recordReference: nonempty(entry["recordReference"] as? String),
                nextPossibleDonationDate: dateValue(entry["nextPossibleDonationDate"])
            ))
        }

        let count = fields["reportedDonationCount"] as? Int
        if let count, count < donations.count {
            throw FirestoreDonorDataError.invalidRecord
        }

        let profile = DonorProfile(
            donorRecordID: recordID,
            displayName: name,
            bloodGroup: bloodGroup,
            reportedDonationCount: count
        )

        return FirestoreDonorRecordPayload(
            ownerUID: nonempty(fields["ownerUID"] as? String),
            recordVerified: fields["recordVerified"] as? Bool == true,
            record: StaffDonorIdentityRecord(
                nicNumber: nic,
                name: name,
                address: address,
                profile: profile,
                donationRecords: donations
            )
        )
    }

    private static func nonempty(_ text: String?) -> String? {
        guard let trimmed = text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else { return nil }
        return trimmed
    }

    private static func dateValue(_ value: Any?) -> Date? {
        if let timestamp = value as? Timestamp { return timestamp.dateValue() }
        return value as? Date
    }
}
