//
//  CameraManager.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

@preconcurrency import AVFoundation
import Vision

enum CameraError: LocalizedError {
    case noCamera
    case cannotConfigure
    
    var errorDescription: String? {
        switch self {
        case .noCamera: return "No camera is available on this device."
        case .cannotConfigure: return "The camera session could not be configured."
        }
    }
}

final class CameraManager: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    let session = AVCaptureSession()
    var onResults: (@Sendable ([BarcodeResult]) -> Void)?
    var onFailure: (@Sendable (Error) -> Void)?

    private let queue = DispatchQueue(label: "barcodestudio.camera")
    private let output = AVCaptureVideoDataOutput()
    private let scanner = VisionBarcodeScanner()
    private var request: VNDetectBarcodesRequest?
    private var isConfigured = false

    static func requestAccess() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }

    /// Validates the mode on the caller's thread so unsupported symbologies fail before any frame is processed.
    func setMode(_ mode: ScanMode) throws {
        let newRequest = try scanner.makeRequest(mode: mode)
        queue.async { self.request = newRequest }
    }

    func start() {
        queue.async {
            do {
                if !self.isConfigured { try self.configure() }
                if !self.session.isRunning { self.session.startRunning() }
            } catch {
                self.onFailure?(error)
            }
        }
    }

    func stop() {
        queue.async { if self.session.isRunning { self.session.stopRunning() } }
    }

    private func configure() throws {
        session.beginConfiguration()
        defer { session.commitConfiguration() }
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            throw CameraError.noCamera
        }
        let input = try AVCaptureDeviceInput(device: device)
        guard session.canAddInput(input), session.canAddOutput(output) else { throw CameraError.cannotConfigure }
        session.addInput(input)
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        session.addOutput(output)
        if let connection = output.connection(with: .video), connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90   // portrait buffers, so Vision orientation is .up
        }
        isConfigured = true
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let request, let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        do {
            let results = try scanner.detect(in: buffer, request: request, orientation: .up)
            onResults?(results)
        } catch {
            onFailure?(error)
        }
    }
}
