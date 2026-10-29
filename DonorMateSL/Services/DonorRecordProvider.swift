//
//  DonorRecordProvider.swift
//  DonorMateSL
//
//  Created by user300742 on 10/23/26.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

nonisolated struct DonorRecordLookupResult: Sendable {
    let profile: DonorProfile
    let records: [DonationRecord]
    let isVerified: Bool
}

nonisolated enum DonorRecordAccessPolicy {
    static func canLink(
        accountUID: String,
        accountNIC: String?,
        ownerUID: String?,
        recordNIC: String
    ) -> Bool {
        guard !accountUID.isEmpty,
              ownerUID == accountUID,
              let accountNIC,
              let validated = NationalIdentityNumberValidator.validated(accountNIC) else {
            return false
        }
        return validated == recordNIC
    }
}

@MainActor
protocol DonorRecordProvider {
    func findRecord(
        account: AccountProfile,
        donorRecordID: String
    ) async throws -> DonorRecordLookupResult?
}

struct FirebaseDonorRecordProvider: DonorRecordProvider {

    func findRecord(
        account: AccountProfile,
        donorRecordID: String
    ) async throws -> DonorRecordLookupResult? {
        let recordID = donorRecordID.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !recordID.isEmpty,
              Auth.auth().currentUser?.uid == account.uid,
              let accountNIC = account.nationalIdentityNumber,
              let validatedNIC = NationalIdentityNumberValidator.validated(accountNIC) else {
            return nil
        }

        let snapshot = try await Firestore.firestore()
            .collection("donorRecords")
            .document(recordID)
            .getDocument(source: .server)

        guard snapshot.exists else { return nil }

        let payload = try FirestoreDonorRecordDecoder.decode(snapshot)
        guard DonorRecordAccessPolicy.canLink(
            accountUID: account.uid,
            accountNIC: validatedNIC,
            ownerUID: payload.ownerUID,
            recordNIC: payload.record.nicNumber
        ) else {
            return nil
        }

        return DonorRecordLookupResult(
            profile: payload.record.profile,
            records: payload.record.donationRecords,
            isVerified: payload.recordVerified
        )
    }
}
