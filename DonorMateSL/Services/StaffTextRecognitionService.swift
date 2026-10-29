//
//  StaffTextRecognitionService.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import Foundation
import Vision

nonisolated enum StaffTextRecognitionError: LocalizedError, Equatable, Sendable {
    case noImage
    case tooManyPages
    case imageTooLarge
    case noReadableText
    case recognitionFailed

    var errorDescription: String? {
        switch self {
        case .noImage:
            return "Choose a clear image of the identity card and try again."
        case .tooManyPages:
            return "Scan up to two sides of the identity card at a time."
        case .imageTooLarge:
            return "This image is too large. Choose a smaller photo and try again."
        case .noReadableText:
            return "No clear English identity details were found. Try a clearer image."
        case .recognitionFailed:
            return "The identity card could not be read. Please try another image."
        }
    }
}

nonisolated enum StaffTextRecognitionService {
    static let maximumPages = 2
    static let maximumImageBytes = 20_000_000

    static func validate(_ images: [Data]) throws {
        guard !images.isEmpty, images.allSatisfy({ !$0.isEmpty }) else {
            throw StaffTextRecognitionError.noImage
        }
        guard images.count <= maximumPages else {
            throw StaffTextRecognitionError.tooManyPages
        }
        guard images.allSatisfy({ $0.count <= maximumImageBytes }) else {
            throw StaffTextRecognitionError.imageTooLarge
        }
    }

    static func recognize(images: [Data]) async throws -> [StaffRecognizedTextLine] {
        try validate(images)

        let worker = Task.detached(priority: .userInitiated) {
            try Self.recognizeOnBackgroundThread(images: images)
        }
        let lines = try await withTaskCancellationHandler {
            try await worker.value
        } onCancel: {
            worker.cancel()
        }

        let englishFields = StaffEnglishNICTextPolicy.extract(from: lines)
        guard !englishFields.isEmpty else {
            throw StaffTextRecognitionError.noReadableText
        }
        return englishFields
    }

    private static func recognizeOnBackgroundThread(
        images: [Data]
    ) throws -> [StaffRecognizedTextLine] {
        var lines: [StaffRecognizedTextLine] = []

        for data in images {
            try Task.checkCancellation()
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate

            request.usesLanguageCorrection = false
            request.recognitionLanguages = ["en-US"]

            do {
                try VNImageRequestHandler(data: data, options: [:]).perform([request])
            } catch {
                throw StaffTextRecognitionError.recognitionFailed
            }

            for observation in request.results ?? [] {
                guard let candidate = observation.topCandidates(1).first else { continue }
                lines.append(.init(
                    text: candidate.string,
                    confidence: candidate.confidence
                ))
            }
        }
        return lines
    }
}
