//
//  StaffAuthFeedbackTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/27/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct StaffAuthFeedbackTests {
    @Test func rejectedCredentialsShowActionableMessage() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17004)
        #expect(
            StaffAuthFeedback.signInMessage(for: error)
            == "We couldn't sign you in. Check your email and password."
        )
    }

    @Test func inactiveOrUnapprovedStaffShowsAccessMessage() {
        let message = StaffAuthFeedback.signInMessage(for: StaffSignInError.notAuthorized)
        #expect(message.contains("not approved"))
    }

    @Test func networkErrorsSuggestRetry() {
        let error = NSError(domain: "FIRAuthErrorDomain", code: 17020)
        #expect(StaffAuthFeedback.signInMessage(for: error).contains("internet connection"))
    }

    @Test func unexpectedErrorsDoNotExposeRawFirebaseMessages() {
        let error = NSError(domain: "FIRFirestoreErrorDomain", code: 7)
        let message = StaffAuthFeedback.signInMessage(for: error)
        #expect(!message.contains("Firebase"))
        #expect(message.contains("Staff access"))
    }
}
