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
