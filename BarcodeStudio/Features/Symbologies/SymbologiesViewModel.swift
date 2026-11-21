//
//  SymbologiesViewModel.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Foundation
import Observation
import Vision

@MainActor
@Observable
final class SymbologiesViewModel {

    private(set) var all: [Symbology] = []
    var search = ""
    var category: SymbologyCategory?
    var errorMessage: String?

    private let repository: SymbologyRepository

    init(repository: SymbologyRepository? = nil) {
        self.repository = repository ?? SymbologyRepository()
    }

    func load() {
        do {
            all = try repository.loadAll()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var filtered: [Symbology] {
        all.filter { item in
            (category == nil || item.category == category) &&
            (search.isEmpty ||
             item.name.localizedCaseInsensitiveContains(search) ||
             item.id.localizedCaseInsensitiveContains(search))
        }
    }
}
