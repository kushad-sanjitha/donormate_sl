//
//  StaffIdentity.swift
//  DonorMateSL
//
//  Created by user300742 on 10/27/26.
//

import Foundation

nonisolated struct StaffIdentity: Equatable, Sendable {
    let uid: String
    let displayName: String
    let locationID: String
    let locationName: String
}

nonisolated enum StaffRoleValidator {
    static func validate(uid: String, fields: [String: Any]) -> StaffIdentity? {
        guard !uid.isEmpty,
              fields["active"] as? Bool == true,
              fields["role"] as? String == "verification_staff",
              let name = fields["displayName"] as? String,
              let locationID = fields["locationID"] as? String,
              let locationName = fields["locationName"] as? String else { return nil }
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLocationID = locationID.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanLocationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty, !cleanLocationID.isEmpty, !cleanLocationName.isEmpty else { return nil }
        return StaffIdentity(uid: uid, displayName: cleanName, locationID: cleanLocationID, locationName: cleanLocationName)
    }
}
