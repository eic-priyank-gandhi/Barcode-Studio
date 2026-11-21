//
//  SymbologiesView.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import SwiftUI

struct SymbologiesView: View {
    @State private var model = SymbologiesViewModel()
    
    var body: some View {
        List(model.filtered) { item in
            NavigationLink(value: item) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.name).font(.headline)
                    HStack(spacing: 8) {
                        StatusPill(label: "Detect", on: item.detectionSupported)
                        StatusPill(label: "Generate", on: item.generation.isAvailable)
                        Text(item.category.rawValue).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Symbologies")
        .searchable(text: $model.search)
        .toolbar {
            Menu {
                Picker("Category", selection: $model.category) {
                    Text("All").tag(SymbologyCategory?.none)
                    ForEach(SymbologyCategory.allCases) { Text($0.rawValue).tag(SymbologyCategory?.some($0)) }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        .navigationDestination(for: Symbology.self) { SymbologiesDetailView(symbology: $0) }
        .task { model.load() }
        .overlay {
            if let message = model.errorMessage {
                ContentUnavailableView("Could not load symbologies", systemImage: "exclamationmark.triangle", description: Text(message))
            }
        }
    }
}

#Preview {
    SymbologiesView()
}
