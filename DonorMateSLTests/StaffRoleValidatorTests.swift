//
//  StaffRoleValidatorTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/27/26.
//

import Testing
@testable import DonorMateSL

@MainActor
struct StaffRoleValidatorTests {
    private let valid: [String: Any] = [
        "active": true,
        "role": "verification_staff",
        "displayName": "Matara Officer",
        "locationID": "matara-bank",
        "locationName": "Matara Blood Bank"
    ]

    @Test func validAuthorizedStaffRecord() {
        let staff = StaffRoleValidator.validate(uid: "uid-a", fields: valid)
        #expect(staff?.uid == "uid-a")
        #expect(staff?.locationName == "Matara Blood Bank")
    }

    @Test func inactiveStaffIsDenied() {
        var fields = valid
        fields["active"] = false
        #expect(StaffRoleValidator.validate(uid: "uid-a", fields: fields) == nil)
    }

    @Test func donorRoleIsDenied() {
        var fields = valid
        fields["role"] = "donor"
        #expect(StaffRoleValidator.validate(uid: "uid-a", fields: fields) == nil)
    }

    @Test func missingLocationIsDenied() {
        var fields = valid
        fields.removeValue(forKey: "locationID")
        #expect(StaffRoleValidator.validate(uid: "uid-a", fields: fields) == nil)
    }

    @Test func emptyUIDIsDenied() {
        #expect(StaffRoleValidator.validate(uid: "", fields: valid) == nil)
    }

    @Test func whitespaceNamesAreDenied() {
        var fields = valid
        fields["displayName"] = "   "
        #expect(StaffRoleValidator.validate(uid: "uid-a", fields: fields) == nil)
    }
}
