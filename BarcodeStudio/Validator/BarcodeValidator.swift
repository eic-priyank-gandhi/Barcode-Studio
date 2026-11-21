//
//  BarcodeValidator.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Foundation

protocol BarcodeValidator: Sendable {
    /// Returns the exact payload to encode (for example with the check digit appended).
    func validate(_ input: String) throws -> String
}

enum GS1CheckDigit {
    static func compute(for digits: [Int]) -> Int {
        var sum = 0
        for (offset, digit) in digits.reversed().enumerated() {
            sum += digit * (offset % 2 == 0 ? 3 : 1)
        }
        return (10 - sum % 10) % 10
    }
}

private func asciiDigits(_ input: String) throws -> [Int] {
    guard !input.isEmpty else { throw BarcodeValidationError.empty }
    var digits: [Int] = []
    for ch in input {
        guard ch.isASCII, let v = ch.wholeNumberValue else { throw BarcodeValidationError.nonDigit }
        digits.append(v)
    }
    return digits
}

private func validateGS1(_ input: String, dataLength: Int) throws -> String {
    let trimmed = input.trimmingCharacters(in: .whitespaces)
    let digits = try asciiDigits(trimmed)
    switch digits.count {
    case dataLength:
        return trimmed + String(GS1CheckDigit.compute(for: digits))
    case dataLength + 1:
        let expected = GS1CheckDigit.compute(for: Array(digits.dropLast()))
        guard digits.last == expected else { throw BarcodeValidationError.badCheckDigit(expected: expected) }
        return trimmed
    default:
        throw BarcodeValidationError.invalidLength(expected: "\(dataLength) or \(dataLength + 1)", actual: digits.count)
    }
}

struct EAN13Validator: BarcodeValidator {
    func validate(_ input: String) throws -> String { try validateGS1(input, dataLength: 12) }
}

struct EAN8Validator: BarcodeValidator {
    func validate(_ input: String) throws -> String { try validateGS1(input, dataLength: 7) }
}

struct UPCAValidator: BarcodeValidator {
    func validate(_ input: String) throws -> String { try validateGS1(input, dataLength: 11) }
}

struct Code39Validator: BarcodeValidator {
    static let alphabet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%")
    var appendMod43Check = false

    func validate(_ input: String) throws -> String {
        guard !input.isEmpty else { throw BarcodeValidationError.empty }
        for ch in input where !Self.alphabet.contains(ch) {
            throw BarcodeValidationError.invalidCharacter(ch)
        }
        guard appendMod43Check else { return input }
        return input + String(Self.mod43CheckCharacter(for: input))
    }

    static func mod43CheckCharacter(for input: String) -> Character {
        let sum = input.compactMap { alphabet.firstIndex(of: $0) }.reduce(0, +)
        return alphabet[sum % 43]
    }
}

struct Code128Validator: BarcodeValidator {
    func validate(_ input: String) throws -> String {
        _ = try Code128Encoder.encode(input)
        return input
    }
}

/// Used for the matrix and stacked symbologies where Core Image does the actual encoding.
struct ByteLimitValidator: BarcodeValidator {
    let maxBytes: Int
    func validate(_ input: String) throws -> String {
        guard !input.isEmpty else { throw BarcodeValidationError.empty }
        guard input.utf8.count <= maxBytes else { throw BarcodeValidationError.tooLong(maxBytes: maxBytes) }
        return input
    }
}
