//
//  StaffScanSession.swift
//  DonorMateSL
//
//  Created by user300742 on 10/29/26.
//

import Foundation

nonisolated enum StaffScanSource: String, Equatable, Sendable {
    case camera
    case photoLibrary
    case files

    var displayName: String {
        switch self {
        case .camera: return "Camera"
        case .photoLibrary: return "Photo library"
        case .files: return "Files"
        }
    }
}

nonisolated struct StaffRecognizedTextLine: Equatable, Sendable {
    let text: String
    let confidence: Float
}

nonisolated struct StaffScanResult: Equatable, Sendable {
    let source: StaffScanSource
    let lines: [StaffRecognizedTextLine]

    var recognizedText: String {
        lines.map(\.text).joined(separator: "\n")
    }
}

nonisolated enum StaffScanStage: Equatable, Sendable {
    case instructions
    case capture
    case processing
    case review
}

nonisolated enum StaffScanTextPolicy {
    static func cleaned(_ lines: [StaffRecognizedTextLine]) -> [StaffRecognizedTextLine] {
        lines.compactMap { line in
            let text = line.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            return StaffRecognizedTextLine(
                text: text,
                confidence: min(1, max(0, line.confidence))
            )
        }
    }
}

nonisolated struct StaffScanSession: Equatable, Sendable {
    private(set) var stage: StaffScanStage = .instructions
    private(set) var result: StaffScanResult?

    mutating func showCapture() {
        result = nil
        stage = .capture
    }

    mutating func beginProcessing() -> Bool {
        guard stage == .capture else { return false }
        result = nil
        stage = .processing
        return true
    }

    @discardableResult
    mutating func complete(source: StaffScanSource, lines: [StaffRecognizedTextLine]) -> Bool {
        guard stage == .processing else { return false }
        let cleanedLines = StaffScanTextPolicy.cleaned(lines)
        guard !cleanedLines.isEmpty else {
            stage = .capture
            return false
        }
        result = StaffScanResult(source: source, lines: cleanedLines)
        stage = .review
        return true
    }

    mutating func failProcessing() {
        guard stage == .processing else { return }
        result = nil
        stage = .capture
    }

    mutating func reset() {
        stage = .instructions
        result = nil
    }
}
