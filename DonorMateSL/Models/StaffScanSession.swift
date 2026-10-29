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

nonisolated enum StaffEnglishNICTextPolicy {
    private static let nicPattern = #"(?<![A-Za-z0-9])(?:[0-9]{12}|[0-9]{9}[VvXx])(?![A-Za-z0-9])"#
    private static let datePattern = #"(?<![0-9])[0-9]{2,4}[/.-][0-9]{2}[/.-][0-9]{2,4}(?![0-9])"#
    private static let sexPattern = #"\b(?:Male|Female)\b"#

    static func extract(from lines: [StaffRecognizedTextLine]) -> [StaffRecognizedTextLine] {
        let source = StaffScanTextPolicy.cleaned(lines)
        var nic: StaffRecognizedTextLine?
        var name: [StaffRecognizedTextLine] = []
        var sex: StaffRecognizedTextLine?
        var birthDate: StaffRecognizedTextLine?
        var address: [StaffRecognizedTextLine] = []

        for index in source.indices {
            let text = source[index].text

            if nic == nil, isNICLabel(text) {
                nic = firstValue(in: source, from: index, lookingAhead: 2, pattern: nicPattern)
            }

            if name.isEmpty, text.range(of: "Name", options: .caseInsensitive) != nil {
                let following = source.dropFirst(index + 1).prefix(3)
                name = Array(following.filter { isEnglishName($0.text) }.prefix(2))
                if let inline = textAfterLabel("Name", in: text), isEnglishName(inline) {
                    name.insert(.init(text: inline, confidence: source[index].confidence), at: 0)
                    name = Array(name.prefix(2))
                }
            }

            if sex == nil, text.range(of: "Sex", options: .caseInsensitive) != nil {
                sex = firstValue(in: source, from: index, lookingAhead: 1, pattern: sexPattern)
            }

            if birthDate == nil, text.range(of: "Date of Birth", options: .caseInsensitive) != nil {
                birthDate = firstValue(in: source, from: index, lookingAhead: 2, pattern: datePattern)
            }

            if address.isEmpty, text.range(of: "Address", options: .caseInsensitive) != nil {
                if let inline = textAfterLabel("Address", in: text), isEnglishAddress(inline) {
                    address.append(.init(text: inline, confidence: source[index].confidence))
                }
                for entry in source.dropFirst(index + 1).prefix(10) {
                    if entry.text.range(of: "Date of Issue", options: .caseInsensitive) != nil {
                        break
                    }
                    if isEnglishAddress(entry.text) {
                        address.append(entry)
                        if address.count == 3 { break }
                    }
                }
            }
        }

        var display: [StaffRecognizedTextLine] = []
        if let nic { display.append(labeled("NIC number", value: nic)) }
        if !name.isEmpty {
            let combined = name.map(\.text).joined(separator: " ")
            display.append(.init(text: "Name: \(combined)", confidence: name[0].confidence))
        }
        if let sex { display.append(labeled("Sex", value: sex)) }
        if let birthDate { display.append(labeled("Date of birth", value: birthDate)) }
        if !address.isEmpty {
            display.append(.init(
                text: "Address: \(address.map(\.text).joined(separator: " "))",
                confidence: address[0].confidence
            ))
        }
        return display
    }

    private static func isNICLabel(_ text: String) -> Bool {
        text.range(of: #"\b(?:NIC|No\s*[.:]|identity number)"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    private static func firstValue(
        in lines: [StaffRecognizedTextLine],
        from index: Int,
        lookingAhead count: Int,
        pattern: String
    ) -> StaffRecognizedTextLine? {
        for line in lines[index...min(index + count, lines.count - 1)] {
            if let range = line.text.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                return .init(text: String(line.text[range]), confidence: line.confidence)
            }
        }
        return nil
    }

    private static func textAfterLabel(_ label: String, in text: String) -> String? {
        guard let range = text.range(of: label, options: .caseInsensitive) else { return nil }
        let suffix = String(text[range.upperBound...])
            .trimmingCharacters(in: CharacterSet(charactersIn: " :|-\t"))
        return suffix.isEmpty ? nil : suffix
    }

    private static func isEnglishName(_ text: String) -> Bool {
        let letters = text.filter { $0.isASCII && $0.isLetter }
        guard letters.count >= 3,
              text.allSatisfy({ ($0.isASCII && $0.isLetter) || " -.'".contains($0) }) else {
            return false
        }
        return letters.filter(\.isUppercase).count * 4 >= letters.count * 3
    }

    private static func isEnglishAddress(_ text: String) -> Bool {
        let words = text.split(whereSeparator: { !$0.isASCII || !$0.isLetter })
        let uppercaseWords = words.filter { word in
            word.count >= 3 && word.allSatisfy(\.isUppercase)
        }
        return uppercaseWords.count >= 2
    }

    private static func labeled(_ label: String, value: StaffRecognizedTextLine) -> StaffRecognizedTextLine {
        .init(text: "\(label): \(value.text)", confidence: value.confidence)
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
