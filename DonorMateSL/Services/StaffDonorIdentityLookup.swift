//
//  StaffDonorIdentityLookup.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

//
//  StaffDonorIdentityLookup.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

@MainActor
protocol StaffDonorIdentityLookup {
    func findRecord(nicNumber: String) async throws -> StaffDonorIdentityRecord?
}

struct FirebaseStaffDonorIdentityLookup: StaffDonorIdentityLookup {

    func findRecord(nicNumber: String) async throws -> StaffDonorIdentityRecord? {
        guard let nic = NationalIdentityNumberValidator.validated(nicNumber) else { return nil }
        guard let app = FirebaseApp.app(name: "DonorMateStaff"),
              Auth.auth(app: app).currentUser != nil else {
            throw StaffSignInError.notAuthorized
        }

        let snapshot = try await Firestore.firestore(app: app)
            .collection("donorRecords")
            .whereField("nationalIdentityNumber", isEqualTo: nic)
            .limit(to: 2)
            .getDocuments(source: .server)

        guard snapshot.documents.count <= 1 else {
            throw FirestoreDonorDataError.duplicateNIC
        }
        guard let document = snapshot.documents.first else { return nil }

        let payload = try FirestoreDonorRecordDecoder.decode(document)
        return payload.record.nicNumber == nic ? payload.record : nil
    }
}
