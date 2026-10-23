//
//  AccountProfile.swift
//  DonorMateSL
//
//  Created by user300742 on 10/22/26.
//

import Foundation

nonisolated struct AccountProfile:
    Equatable,
    Sendable {

    let uid: String
    let displayName: String
    let email: String
    let nationalIdentityNumber: String?

    init(
        uid: String,
        displayName: String,
        email: String,
        nationalIdentityNumber: String? = nil
    ) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.nationalIdentityNumber =
            nationalIdentityNumber
    }

    var hasNationalIdentityNumber: Bool {
        guard let nationalIdentityNumber else {
            return false
        }

        return NationalIdentityNumberValidator
            .isValid(
                nationalIdentityNumber
            )
    }

    var maskedNationalIdentityNumber: String? {
        guard let nationalIdentityNumber,
              hasNationalIdentityNumber else {
            return nil
        }

        return NationalIdentityNumberValidator
            .masked(
                nationalIdentityNumber
            )
    }
}
