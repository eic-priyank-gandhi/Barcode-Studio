//
//  BarcodeGenerator.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import Foundation
import CoreGraphics

protocol BarcodeGenerator: Sendable {
    /// Matches `VNBarcodeSymbology.rawValue` of the symbology this generator produces.
    var symbologyKey: String { get }
    var validator: BarcodeValidator { get }
    func generate(_ input: String, options: GenerationOptions) throws -> CGImage
}

enum QRCorrectionLevel: String, CaseIterable, Identifiable, Sendable {
    case low = "L", medium = "M", quartile = "Q", high = "H"
    var id: String { rawValue }
}

struct GenerationOptions: Sendable {
    var scale: CGFloat = 8
    var qrCorrection: QRCorrectionLevel = .medium
    /// Aztec error-correction percentage (Core Image accepts 5...95).
    var aztecCorrectionPercent: Int = 23
}

enum BarcodeGenerationError: LocalizedError {
    case filterUnavailable(String)
    case renderingFailed
    case unsupported(String)

    var errorDescription: String? {
        switch self {
        case let .filterUnavailable(name): return "Core Image filter \(name) is not available on this system."
        case .renderingFailed: return "The barcode image could not be rendered."
        case let .unsupported(reason): return reason
        }
    }
}
