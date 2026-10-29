//
//  StaffScanSessionTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/29/26.
//

import Testing
@testable import DonorMateSL

@MainActor
struct StaffScanSessionTests {

    @Test func startsAtInstructionsWithoutSensitiveResult() {
        let scan = StaffScanSession()
        #expect(scan.stage == .instructions)
        #expect(scan.result == nil)
    }

    @Test func openingCaptureClearsPreviousResult() {
        var scan = completedScan()
        scan.showCapture()
        #expect(scan.stage == .capture)
        #expect(scan.result == nil)
    }

    @Test func processingCannotStartBeforeCapture() {
        var scan = StaffScanSession()
        let started = scan.beginProcessing()

        #expect(!started)
        #expect(scan.stage == .instructions)
    }

    @Test func validScanReachesReviewWithItsSource() {
        let scan = completedScan()
        #expect(scan.stage == .review)
        #expect(scan.result?.source == .photoLibrary)
        #expect(scan.result?.recognizedText == "FIRST LINE\nSECOND LINE")
    }

    @Test func blankRecognitionDoesNotApproveOrRetainResult() {
        var scan = StaffScanSession()
        scan.showCapture()

        let started = scan.beginProcessing()
        #expect(started)

        let completed = scan.complete(
            source: .camera,
            lines: [.init(text: " \n ", confidence: 0.8)]
        )

        #expect(!completed)
        #expect(scan.stage == .capture)
        #expect(scan.result == nil)
    }

    @Test func failedProcessingReturnsToCapture() {
        var scan = StaffScanSession()
        scan.showCapture()

        let started = scan.beginProcessing()
        #expect(started)

        scan.failProcessing()

        #expect(scan.stage == .capture)
        #expect(scan.result == nil)
    }

    @Test func resetDiscardsRecognitionData() {
        var scan = completedScan()
        scan.reset()
        #expect(scan.stage == .instructions)
        #expect(scan.result == nil)
    }

    @Test func linesTrimWhitespaceAndKeepOrder() {
        let lines = StaffScanTextPolicy.cleaned([
            .init(text: "  FIRST ", confidence: 1.2),
            .init(text: "\n", confidence: 0.5),
            .init(text: " SECOND  ", confidence: -0.2)
        ])

        #expect(lines.map(\.text) == ["FIRST", "SECOND"])
        #expect(lines.map(\.confidence) == [1, 0])
    }

    @Test func frontOfCardShowsOnlyEnglishIdentityDetails() {
        let result = StaffEnglishNICTextPolicy.extract(from: [
            .init(text: "9Cuto", confidence: 0.34),
            .init(text: "SRILANKA", confidence: 0.95),
            .init(text: "NATIONAL IDENTITY CARD", confidence: 0.98),
            .init(text: "No.: 000000000000", confidence: 0.92),
            .init(text: "do>uta", confidence: 0.4),
            .init(text: "Name :", confidence: 0.98),
            .init(text: "JOHN CITIZEN", confidence: 0.97),
            .init(text: "WILLIAMS", confidence: 0.95),
            .init(text: "d§ guio / Sex: 858 / Male", confidence: 0.7),
            .init(text: "Date of Birth :", confidence: 0.88),
            .init(text: "0000/00/00", confidence: 0.91)
        ])

        #expect(result.map(\.text) == [
            "NIC number: 000000000000",
            "Name: JOHN CITIZEN WILLIAMS",
            "Sex: Male",
            "Date of birth: 0000/00/00"
        ])
    }

    @Test func backOfCardShowsEnglishAddressWithoutScriptNoise() {
        let result = StaffEnglishNICTextPolicy.extract(from: [
            .init(text: "8Bina / gpsaufi | Address :", confidence: 0.7),
            .init(text: "000000000V", confidence: 0.9),
            .init(text: "00Y00000 -O", confidence: 0.4),
            .init(text: "OO/O, SRI SARALANKARA", confidence: 0.92),
            .init(text: "MAWATHA, WELMILLA", confidence: 0.9),
            .init(text: "S Sur ie", confidence: 0.2),
            .init(text: "Saoi Dg Qou", confidence: 0.21),
            .init(text: "Date of Issue", confidence: 0.9)
        ])

        #expect(result.map(\.text) == [
            "Address: OO/O, SRI SARALANKARA MAWATHA, WELMILLA"
        ])
    }

    @Test func keepsRecognizedNICCharactersWithoutGuessingCorrections() {
        let wrong = StaffEnglishNICTextPolicy.extract(from: [
            .init(text: "No.: 2OOO12345678", confidence: 0.99)
        ])
        #expect(wrong.isEmpty)

        let exact = StaffEnglishNICTextPolicy.extract(from: [
            .init(text: "No.: 200012345678", confidence: 0.9)
        ])
        #expect(exact.map(\.text) == ["NIC number: 200012345678"])
    }

    @Test func legacyNICIsDisplayedExactlyAsRead() {
        let result = StaffEnglishNICTextPolicy.extract(from: [
            .init(text: "NIC: 912345678v", confidence: 0.9)
        ])
        #expect(result.map(\.text) == ["NIC number: 912345678v"])
    }

    @Test func unrelatedOrGarbledTextDoesNotBecomeAnIdentityField() {
        let result = StaffEnglishNICTextPolicy.extract(from: [
            .init(text: "S Sur ie", confidence: 0.1),
            .init(text: "saoi Dg Qou", confidence: 0.2),
            .init(text: "Commissioner General", confidence: 0.9),
            .init(text: "Registration of Persons Act, No. 32", confidence: 0.9)
        ])
        #expect(result.isEmpty)
    }

    private func completedScan() -> StaffScanSession {
        var scan = StaffScanSession()
        scan.showCapture()
        _ = scan.beginProcessing()

        _ = scan.complete(
            source: .photoLibrary,
            lines: [
                .init(text: "FIRST LINE", confidence: 0.95),
                .init(text: "SECOND LINE", confidence: 0.9)
            ]
        )

        return scan
    }
}
