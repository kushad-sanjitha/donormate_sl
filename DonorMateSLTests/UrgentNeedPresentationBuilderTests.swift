//
//  UrgentNeedPresentationBuilderTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/24/26.
//

import Foundation
import Testing
@testable import DonorMateSL

struct UrgentNeedPresentationBuilderTests {

    private var need: UrgentBloodNeed {
        DonorTestFixtures.urgentNeed
    }

    private var activeDate: Date {
        need.publishedAt.addingTimeInterval(3_600)
    }

    private func linked(bloodGroup: String = "A+") -> DonorLinkState {
        .linked(profile: DonorProfile(
            donorRecordID: "DM-248013",
            displayName: "Example Donor",
            bloodGroup: bloodGroup,
            reportedDonationCount: 4
        ))
    }

    private func build(
        linkState: DonorLinkState,
        readiness: DonationReadinessState,
        date: Date? = nil
    ) -> UrgentNeedPresentation {
        UrgentNeedPresentationBuilder.presentation(
            for: need,
            linkState: linkState,
            readiness: readiness,
            currentDate: date ?? activeDate
        )
    }

    @Test
    func readyAndMatchingShowsDateCheckNotMedicalApproval() {
        let result = build(linkState: linked(), readiness: .ready)
        #expect(result.state == .ready)
        #expect(result.canOfferDonationActions)
        #expect(result.matchText == "A+ match")
        #expect(result.requestTitle == "A+ blood request")
        #expect(result.statusTitle.contains("waiting period"))
        #expect(result.statusDetail.contains("staff"))
    }

    @Test
    func matchingButWaitingDoesNotOfferDonationActions() {
        let result = build(
            linkState: linked(),
            readiness: .notReady(daysRemaining: 17)
        )
        #expect(result.state == .waiting(daysRemaining: 17))
        #expect(!result.canOfferDonationActions)
        #expect(result.statusDetail.contains("17 days"))
    }

    @Test
    func oneDayRemainingUsesSingularWord() {
        let result = build(
            linkState: linked(),
            readiness: .notReady(daysRemaining: 1)
        )
        #expect(result.statusDetail.contains("1 day remaining"))
    }

    @Test
    func inconsistentNonpositiveWaitingDaysIsNotTreatedAsValid() {
        let result = build(
            linkState: linked(),
            readiness: .notReady(daysRemaining: 0)
        )
        #expect(result.state == .readinessUnknown)
        #expect(!result.canOfferDonationActions)
    }

    @Test
    func unknownReadinessDoesNotOfferDonationActions() {
        let result = build(linkState: linked(), readiness: .unknown)
        #expect(result.state == .readinessUnknown)
        #expect(!result.canOfferDonationActions)
    }

    @Test
    func unlinkedDonorCannotBeAssumedMatching() {
        let result = build(linkState: .unlinked, readiness: .ready)
        #expect(result.state == .unlinked)
        #expect(result.matchText == "A+ requested")
        #expect(!result.canOfferDonationActions)
    }

    @Test
    func incompatibleGroupDoesNotGetAReadyLabel() {
        let result = build(linkState: linked(bloodGroup: "B+"), readiness: .ready)
        #expect(result.state == .notMatching)
        #expect(!result.canOfferDonationActions)
        #expect(result.matchText == "A+ requested")
    }

    @Test
    func caseAndWhitespaceDoNotPreventExactMatching() {
        let result = build(linkState: linked(bloodGroup: "  a+  "), readiness: .ready)
        #expect(result.state == .ready)
    }

    @Test
    func missingBloodGroupDoesNotGetAReadyLabel() {
        let result = build(linkState: linked(bloodGroup: "  "), readiness: .ready)
        #expect(result.state == .bloodGroupUnavailable)
        #expect(!result.canOfferDonationActions)
    }

    @Test
    func requestBeforePublicationIsInactive() {
        let result = build(
            linkState: linked(),
            readiness: .ready,
            date: need.publishedAt.addingTimeInterval(-1)
        )
        #expect(result.state == .inactive)
        #expect(!result.canOfferDonationActions)
    }

    @Test
    func expiredRequestIsInactiveEvenForReadyDonor() {
        let result = build(
            linkState: linked(),
            readiness: .ready,
            date: need.expiresAt
        )
        #expect(result.state == .inactive)
        #expect(!result.canOfferDonationActions)
    }
}
