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
}
