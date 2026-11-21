//
//  BarcodeValidationError.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Foundation

enum BarcodeValidationError: LocalizedError, Equatable {
    case empty
    case nonDigit
    case invalidLength(expected: String, actual: Int)
    case invalidCharacter(Character)
    case badCheckDigit(expected: Int)
    case nonASCII
    case tooLong(maxBytes: Int)

    var errorDescription: String? {
        switch self {
        case .empty: return "Enter some data."
        case .nonDigit: return "Only digits 0-9 are allowed."
        case let .invalidLength(expected, actual): return "Expected \(expected) digits, got \(actual)."
        case let .invalidCharacter(c): return "Character \"\(c)\" is not allowed in this symbology."
        case let .badCheckDigit(expected): return "Check digit is wrong. Expected \(expected)."
        case .nonASCII: return "Only ASCII characters (0-127) are allowed."
        case let .tooLong(max): return "Data is too long. Limit used here: \(max) bytes."
        }
    }
}
