//
//  VisionBarcodeScanner.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

import Vision
import CoreVideo
import CoreGraphics

enum ScannerError: LocalizedError {
    case unsupportedSymbology(String)
    var errorDescription: String? {
        switch self {
        case let .unsupportedSymbology(name): return "\(name) is not supported for detection on this device."
        }
    }
}

struct VisionBarcodeScanner: Sendable {
    /// Vision-level filtering: `request.symbologies` restricts what Vision searches for, which saves work
    /// and avoids false positives from other formats. Filtering results afterwards would still make Vision
    /// try every format on every frame.
    func makeRequest(mode: ScanMode) throws -> VNDetectBarcodesRequest {
        let request = VNDetectBarcodesRequest()
        let supported = try request.supportedSymbologies()
        switch mode {
        case .all:
            request.symbologies = supported
        case .selected(let symbology):
            guard supported.contains(symbology) else { throw ScannerError.unsupportedSymbology(symbology.rawValue) }
            request.symbologies = [symbology]
        }
        return request
    }

    func detect(in pixelBuffer: CVPixelBuffer, request: VNDetectBarcodesRequest,
                orientation: CGImagePropertyOrientation = .up) throws -> [BarcodeResult] {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        try handler.perform([request])
        return Self.results(from: request)
    }

    func detect(in image: CGImage, request: VNDetectBarcodesRequest) throws -> [BarcodeResult] {
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        try handler.perform([request])
        return Self.results(from: request)
    }

    private static func results(from request: VNDetectBarcodesRequest) -> [BarcodeResult] {
        (request.results ?? []).map {
            BarcodeResult(payload: $0.payloadStringValue, symbology: $0.symbology,
                          boundingBox: $0.boundingBox, confidence: $0.confidence)
        }
    }
}
