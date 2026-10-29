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

import Foundation

@MainActor
protocol StaffDonorIdentityLookup {
    func findRecord(nicNumber: String) async throws -> StaffDonorIdentityRecord?
}

struct DemoStaffDonorIdentityLookup: StaffDonorIdentityLookup {
    static let sampleNIC = "200012345678"
    static let sampleAddress = "24 LAKE ROAD, MATARA"

    func findRecord(nicNumber: String) async throws -> StaffDonorIdentityRecord? {
        guard let nic = NationalIdentityNumberValidator.validated(nicNumber),
              nic == Self.sampleNIC else { return nil }

        return StaffDonorIdentityRecord(
            nicNumber: Self.sampleNIC,
            name: DonorDemoData.profile.displayName,
            address: Self.sampleAddress,
            profile: DonorDemoData.profile,
            donationRecords: DonorDemoData.records
        )
    }
}
