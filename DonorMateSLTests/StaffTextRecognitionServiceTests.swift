//
//  StaffTextRecognitionServiceTests.swift
//  DonorMateSLTests
//
//  Created by user300742 on 10/29/26.
//

import Foundation
import Testing
@testable import DonorMateSL

@MainActor
struct StaffTextRecognitionServiceTests {
    @Test func rejectsMissingImage() {
        #expect(throws: StaffTextRecognitionError.noImage) {
            try StaffTextRecognitionService.validate([])
        }
    }

    @Test func rejectsEmptyImageData() {
        #expect(throws: StaffTextRecognitionError.noImage) {
            try StaffTextRecognitionService.validate([Data()])
        }
    }

    @Test func acceptsOneOrTwoNonemptyImages() throws {
        try StaffTextRecognitionService.validate([Data([1, 2, 3])])
        try StaffTextRecognitionService.validate([Data([1]), Data([2])])
    }

    @Test func rejectsMoreThanTwoPages() {
        #expect(throws: StaffTextRecognitionError.tooManyPages) {
            try StaffTextRecognitionService.validate([
                Data([1]), Data([2]), Data([3])
            ])
        }
    }

    @Test func rejectsOversizedImageBeforeReading() {
        let oversized = Data(count: StaffTextRecognitionService.maximumImageBytes + 1)
        #expect(throws: StaffTextRecognitionError.imageTooLarge) {
            try StaffTextRecognitionService.validate([oversized])
        }
    }

    @Test func errorsAreSuitableForStaffDisplay() {
        for error in [
            StaffTextRecognitionError.noImage,
            .tooManyPages,
            .imageTooLarge,
            .noReadableText,
            .recognitionFailed
        ] {
            let text = error.localizedDescription
            #expect(!text.isEmpty)
            #expect(!text.contains("Vision"))
        }
    }
}
