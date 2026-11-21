//
//  GeneratorRegistry.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Foundation

/// Generation capability registry. Independent from Vision detection support.
struct GeneratorRegistry: Sendable {
    private let generators: [String: CoreImageBarcodeGenerator]

    init(generators: [CoreImageBarcodeGenerator] = CoreImageGenerators.all()) {
        self.generators = Dictionary(uniqueKeysWithValues: generators.map { ($0.symbologyKey, $0) })
    }

    /// Returns a generator only when its Core Image filter exists at runtime.
    func generator(for key: String) -> (any BarcodeGenerator)? {
        guard let g = generators[key], CoreImageBarcodeGenerator.isFilterAvailable(g.filterName) else { return nil }
        return g
    }

    func availability(for key: String) -> GenerationAvailability {
        if let g = generators[key] {
            return CoreImageBarcodeGenerator.isFilterAvailable(g.filterName)
                ? .available(framework: "Core Image (\(g.filterName))")
                : .unavailable(reason: "\(g.filterName) is not present on this OS version.")
        }
        return .unavailable(reason: "No built-in Core Image generator for this format, and no custom encoder is implemented yet.")
    }
}
