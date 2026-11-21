//
//  GeneratorViewModel.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

import Foundation
import UIKit
import Vision

@MainActor
@Observable
final class GeneratorViewModel {
    struct Option: Identifiable, Hashable { let id: String; let name: String }

     var options: [Option] = []
     var selectedID: String
     var input = ""
     var generation = GenerationOptions()
     private(set) var image: UIImage?
     private(set) var errorMessage: String?

    private let registry: GeneratorRegistry
    private let repository: SymbologyRepository

    init(preselected: String? = nil, registry: GeneratorRegistry = GeneratorRegistry()) {
        self.registry = registry
        self.repository = SymbologyRepository(generators: registry)
        self.selectedID = preselected ?? VNBarcodeSymbology.qr.rawValue
    }

    func load() {
        let all = (try? repository.loadAll()) ?? []
        options = all.filter { $0.generation.isAvailable }.map { Option(id: $0.id, name: $0.name) }
        if !options.contains(where: { $0.id == selectedID }), let first = options.first { selectedID = first.id }
    }

    func generate() {
        errorMessage = nil
        guard let generator = registry.generator(for: selectedID) else {
            image = nil; errorMessage = "No generator is available for this symbology."; return
        }
        do {
            image = UIImage(cgImage: try generator.generate(input, options: generation))
        } catch {
            image = nil; errorMessage = error.localizedDescription
        }
    }
}
