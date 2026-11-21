//
//  Symbology.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Vision

enum GenerationAvailability: Equatable, Sendable {
    case available(framework: String)
    case unavailable(reason: String)

    var isAvailable: Bool {
        if case .available = self { return true }
        return false
    }
}

struct Symbology: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let category: SymbologyCategory
    let summary: String
    let applications: String
    let dataFormat: String
    let vision: VNBarcodeSymbology?
    let detectionSupported: Bool
    let generation: GenerationAvailability

    static func == (lhs: Symbology, rhs: Symbology) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}


