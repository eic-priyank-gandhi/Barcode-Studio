//
//  SymbologyRepository.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Foundation
import Vision

protocol SymbologyProviding: Sendable {
    func supportedSymbologies() throws -> [VNBarcodeSymbology]
}

struct VisionSymbologyProvider: SymbologyProviding {
    func supportedSymbologies() throws -> [VNBarcodeSymbology] {
        try VNDetectBarcodesRequest().supportedSymbologies()
    }
}

struct SymbologyRepository: Sendable {
    let provider: any SymbologyProviding
    let generators: GeneratorRegistry

    init(provider: any SymbologyProviding = VisionSymbologyProvider(), generators: GeneratorRegistry = GeneratorRegistry()) {
        self.provider = provider
        self.generators = generators
    }

    /// Everything Vision reports (never hardcoded), plus generation-only entries.
    func loadAll() throws -> [Symbology] {
        let supported = try provider.supportedSymbologies()
        var result = supported.map { vision -> Symbology in
            let ref = SymbologyCatalog.reference(for: vision)
            return Symbology(id: vision.rawValue, name: ref.name, category: ref.category, summary: ref.summary,
                             applications: ref.applications, dataFormat: ref.dataFormat, vision: vision,
                             detectionSupported: true, generation: generators.availability(for: vision.rawValue))
        }
        result.append(Symbology(
            id: SymbologyCatalog.upcAKey, name: "UPC-A", category: .retail,
            summary: "12-digit retail code. Vision has no separate UPC-A identifier; it reports UPC-A as EAN-13 with a leading 0.",
            applications: "North American retail", dataFormat: "12 digits",
            vision: nil, detectionSupported: false,
            generation: generators.availability(for: SymbologyCatalog.upcAKey)))
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
