//
//  SymbologiesDetailView.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

import SwiftUI
import Vision

struct SymbologiesDetailView: View {
    let symbology: Symbology
    
    var body: some View {
        List {
            Section("General") {
                row("Name", symbology.name)
                row("Identifier", symbology.id)
                row("Category", symbology.category.rawValue)
                row("Data format", symbology.dataFormat)
                Text(symbology.summary)
                row("Common uses", symbology.applications)
            }
            Section("Detection") {
                row("Vision support", symbology.detectionSupported ? "Reported by Vision at runtime" : "Not reported")
                row("API", "VNDetectBarcodesRequest")
                Text("Scanning this symbology sets request.symbologies to just this one value, so Vision itself skips other formats. That differs from scanning everything and discarding results afterwards.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            Section("Generation") {
                switch symbology.generation {
                case .available(let framework): row("Implementation", framework)
                case .unavailable(let reason): Text(reason).foregroundStyle(.secondary)
                }
            }
            Section("Actions") {
                if let vision = symbology.vision, symbology.detectionSupported {
                    NavigationLink("Scan This Symbology") { ScannerView(mode: .selected(vision), title: symbology.name) }
                } else {
                    Text("Scan This Symbology is unavailable: Vision does not report this format.").foregroundStyle(.secondary)
                }
                if symbology.generation.isAvailable {
                    NavigationLink("Generate This Symbology") { GeneratorView(preselected: symbology.id) }
                } else {
                    Text("Generate This Symbology is disabled: no implemented generator.").foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func row(_ title: String, _ value: String) -> some View {
        LabeledContent(title) { Text(value).multilineTextAlignment(.trailing) }
    }
}

#Preview {
    SymbologiesDetailView(symbology: Symbology(id: "1", name: "Code 128", category: .oneD, summary: "High-density linear code with code sets A, B and C and a mod-103 checksum.", applications: "Shipping labels, logistics", dataFormat: "Full ASCII", vision: VNBarcodeSymbology.code128, detectionSupported: true, generation: .available(framework: "Vision")))
}
