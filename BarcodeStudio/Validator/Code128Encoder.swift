//
//  Code128Encoder.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Foundation

enum Code128Encoder {
    enum CodeSet { case a, b, c }

    struct Encoding: Equatable {
        let symbolValues: [Int]   // start code first, data and switch codes after
        let checksum: Int
        static let stop = 106
        var fullSequence: [Int] { symbolValues + [checksum, Self.stop] }
    }

    private static let startA = 103, startB = 104, startC = 105
    private static let switchToC = 99, switchToB = 100, switchToA = 101

    static func encode(_ input: String) throws -> Encoding {
        guard !input.isEmpty else { throw BarcodeValidationError.empty }
        let chars = input.unicodeScalars.map { Int($0.value) }
        guard chars.allSatisfy({ $0 < 128 }) else { throw BarcodeValidationError.nonASCII }

        func isDigit(_ v: Int) -> Bool { v >= 48 && v <= 57 }
        func digitRun(from i: Int) -> Int {
            var n = 0
            while i + n < chars.count, isDigit(chars[i + n]) { n += 1 }
            return n
        }
        func value(_ c: Int, in set: CodeSet) -> Int {
            switch set {
            case .b: return c - 32
            case .a: return c < 32 ? c + 64 : c - 32
            case .c: return c
            }
        }

        var codes: [Int] = []
        var set: CodeSet
        let initialRun = digitRun(from: 0)
        if initialRun >= 4 || (initialRun == chars.count && initialRun >= 2 && initialRun % 2 == 0) {
            set = .c; codes.append(startC)
        } else if chars[0] < 32 {
            set = .a; codes.append(startA)
        } else {
            set = .b; codes.append(startB)
        }

        var i = 0
        while i < chars.count {
            switch set {
            case .c:
                if i + 1 < chars.count, isDigit(chars[i]), isDigit(chars[i + 1]) {
                    codes.append((chars[i] - 48) * 10 + (chars[i + 1] - 48))
                    i += 2
                } else if chars[i] < 32 {
                    codes.append(switchToA); set = .a
                } else {
                    codes.append(switchToB); set = .b
                }
            case .a, .b:
                let run = digitRun(from: i)
                if run >= 6 || (run >= 4 && i + run == chars.count) {
                    if run % 2 == 1 {                       // emit one digit in the current set first
                        codes.append(value(chars[i], in: set)); i += 1
                    }
                    codes.append(switchToC); set = .c
                    continue
                }
                let c = chars[i]
                if set == .b, c < 32 { codes.append(switchToA); set = .a }
                else if set == .a, c >= 96 { codes.append(switchToB); set = .b }
                codes.append(value(c, in: set))
                i += 1
            }
        }

        var sum = codes[0]
        for (index, v) in codes.enumerated().dropFirst() { sum += index * v }
        return Encoding(symbolValues: codes, checksum: sum % 103)
    }
}
