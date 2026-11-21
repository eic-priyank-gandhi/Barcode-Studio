//
//  GeneratorView.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

import SwiftUI
import Vision

struct GeneratorView: View {
    @State private var model: GeneratorViewModel
    init(preselected: String? = nil) { _model = State(wrappedValue: GeneratorViewModel(preselected: preselected)) }

    var body: some View {
        Form {
            Section("Symbology") {
                Picker("Format", selection: $model.selectedID) {
                    ForEach(model.options) { Text($0.name).tag($0.id) }
                }
            }
            Section("Data") {
                TextField("Barcode data", text: $model.input, axis: .vertical)
                    .textInputAutocapitalization(.never).autocorrectionDisabled()
                if model.selectedID == VNBarcodeSymbology.qr.rawValue {
                    Picker("Error correction", selection: $model.generation.qrCorrection) {
                        ForEach(QRCorrectionLevel.allCases) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented)
                }
                Button("Generate") { model.generate() }.disabled(model.input.isEmpty)
            }
            if let message = model.errorMessage {
                Section { Text(message).foregroundStyle(.red) }
            }
            if let image = model.image {
                Section("Preview") {
                    Image(uiImage: image).interpolation(.none).resizable().scaledToFit()
                        .accessibilityLabel("Generated barcode")
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("Barcode", image: Image(uiImage: image)))
                }
            }
        }
        .navigationTitle("Generator")
        .task { model.load() }
    }
}


#Preview {
    GeneratorView()
}
