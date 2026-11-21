//
//  ScannerViewModel.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

import AVFoundation
import Foundation
import Vision

@MainActor
@Observable
final class ScannerViewModel {
    enum Access { case unknown, granted, denied }

    private(set) var visible: [BarcodeResult] = []
    private(set) var history: [BarcodeResult] = []
    private(set) var access: Access = .unknown
    var errorMessage: String?

    let mode: ScanMode
    let camera: CameraManager
    private var lastSeen: [String: Date] = [:]
    private let duplicateWindow: TimeInterval = 4

    init(mode: ScanMode = .all, camera: CameraManager = CameraManager()) {
        self.mode = mode
        self.camera = camera
    }

    func start() async {
        guard await CameraManager.requestAccess() else { access = .denied; return }
        access = .granted
        camera.onResults = { [weak self] results in
            Task { @MainActor in self?.handle(results) }
        }
        camera.onFailure = { [weak self] error in
            Task { @MainActor in self?.errorMessage = error.localizedDescription }
        }
        do {
            try camera.setMode(mode)
            camera.start()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stop() { camera.stop() }

    private func handle(_ results: [BarcodeResult]) {
        visible = results
        let now = Date()
        for result in results {
            if let last = lastSeen[result.dedupeKey], now.timeIntervalSince(last) < duplicateWindow {
                lastSeen[result.dedupeKey] = now
                continue
            }
            lastSeen[result.dedupeKey] = now
            history.insert(result, at: 0)
        }
    }
}
