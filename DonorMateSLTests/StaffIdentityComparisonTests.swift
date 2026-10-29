//
//  StaffIdentityComparisonTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/29/26.
//

import Testing
@testable import DonorMateSL

@MainActor
struct StaffIdentityComparisonTests {
    private let sampleNIC = DemoStaffDonorIdentityLookup.sampleNIC
    private let sampleAddress = DemoStaffDonorIdentityLookup.sampleAddress

    @Test func extractsOnlyLabeledFieldsFromScanResult() {
        let scan = StaffScanResult(source: .photoLibrary, lines: [
            .init(text: "NIC number: 200012345678", confidence: 0.9),
            .init(text: "Name: Sample Donor", confidence: 0.8),
            .init(text: "Sex: Male", confidence: 0.95),
            .init(text: "Address: 24 LAKE ROAD, MATARA", confidence: 0.8)
        ])
        let fields = StaffIdentityFields(result: scan)

        #expect(fields.nicNumber == sampleNIC)
        #expect(fields.name == "Sample Donor")
        #expect(fields.address == sampleAddress)
    }

    @Test func allFieldsAgreeWithoutChangingOCRCharacters() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(name: "  sample   donor ", address: "24 lake road, matara"),
            record: sampleRecord()
        )
        #expect(result.outcome == .allFieldsAgree)
        #expect(result.canOpenSampleRecord)
    }

    @Test func addressDifferenceRequiresHumanAcknowledgement() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(address: "25 LAKE ROAD, MATARA"),
            record: sampleRecord()
        )
        #expect(result.outcome == .addressNeedsReview)
        #expect(result.canOpenSampleRecord)
    }

    @Test func absentBackOfNICAlsoRequiresAddressReview() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(address: nil),
            record: sampleRecord()
        )
        #expect(result.outcome == .addressNeedsReview)
    }

    @Test func differentNameCannotBeApproved() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(name: "JOHN CITIZEN WILLIAMS"),
            record: sampleRecord()
        )
        #expect(result.outcome == .nameMismatch)
        #expect(!result.canOpenSampleRecord)
    }

    @Test func missingNameNeverAgrees() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(name: nil),
            record: sampleRecord()
        )
        #expect(result.outcome == .insufficientDetails)
        #expect(!result.canOpenSampleRecord)
    }

    @Test func noValidNICNeverAgreesEvenWithMatchingName() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(nic: "000000000000"),
            record: sampleRecord()
        )
        #expect(result.outcome == .insufficientDetails)
    }

    @Test func nonMatchingNICCannotUseAnotherPersonsRecord() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(nic: "200112345678"),
            record: sampleRecord()
        )
        #expect(result.outcome == .recordNotFound)
        #expect(result.record == nil)
        #expect(!result.canOpenSampleRecord)
    }

    @Test func ocrLetterODoesNotGetChangedIntoZero() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(nic: "2OOO12345678"),
            record: sampleRecord()
        )
        #expect(result.outcome == .insufficientDetails)
    }

    @Test func validNICWithNoRecordIsNotFound() {
        let result = StaffIdentityComparison.evaluate(
            scanned: fields(),
            record: nil
        )
        #expect(result.outcome == .recordNotFound)
    }

    @Test func demoLookupReturnsOnlyItsFixture() async throws {
        let lookup = DemoStaffDonorIdentityLookup()
        let found = try await lookup.findRecord(nicNumber: sampleNIC)
        let unknown = try await lookup.findRecord(nicNumber: "200112345678")

        #expect(found?.profile == DonorDemoData.profile)
        #expect(found?.donationRecords.count == DonorDemoData.records.count)
        #expect(found?.name == DonorDemoData.profile.displayName)
        #expect(unknown == nil)
    }

    private func fields(
        nic: String? = "200012345678",
        name: String? = "Sample Donor",
        address: String? = "24 LAKE ROAD, MATARA"
    ) -> StaffIdentityFields {
        .init(nicNumber: nic, name: name, address: address)
    }

    private func sampleRecord() -> StaffDonorIdentityRecord {
        .init(
            nicNumber: sampleNIC,
            name: DonorDemoData.profile.displayName,
            address: sampleAddress,
            profile: DonorDemoData.profile,
            donationRecords: DonorDemoData.records
        )
    }
}
