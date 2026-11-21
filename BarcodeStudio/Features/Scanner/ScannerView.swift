//
//  ScannerView.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

import SwiftUI

struct ScannerView: View {
    @State private var model: ScannerViewModel
    private let title: String

    init(mode: ScanMode = .all, title: String = "Scan All") {
        _model = State(wrappedValue: ScannerViewModel(mode: mode))
        self.title = title
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            switch model.access {
            case .denied:
                ContentUnavailableView("Camera access is off", systemImage: "camera.fill",
                    description: Text("Enable camera access for Barcode Studio in Settings."))
            default:
                CameraPreview(session: model.camera.session, results: model.visible).ignoresSafeArea()
                resultsPanel
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .task { await model.start() }
        .onDisappear { model.stop() }
        .alert("Scanner error", isPresented: Binding(get: { model.errorMessage != nil },
                                                    set: { if !$0 { model.errorMessage = nil } })) {
            Button("OK", role: .cancel) {}
        } message: { Text(model.errorMessage ?? "") }
    }
    
    private var resultsPanel: some View {
        List(model.history) { result in
            VStack(alignment: .leading, spacing: 4) {
                Text(result.payload ?? "(binary payload)").font(.body.monospaced()).lineLimit(3)
                Text(SymbologyCatalog.reference(for: result.symbology).name).font(.caption).foregroundStyle(.secondary)
            }
            .contextMenu {
                if let payload = result.payload {
                    Button("Copy", systemImage: "doc.on.doc") { UIPasteboard.general.string = payload }
                }
            }
        }
        .listStyle(.plain)
        .frame(maxHeight: 240)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}

#Preview {
    ScannerView()
}
