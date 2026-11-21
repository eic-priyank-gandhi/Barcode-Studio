//
//  CoreImageBarcodeGenerator.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import CoreImage
import Vision

/// Generator backed by a built-in Core Image barcode filter. The filter name decides the format,
/// so the produced image can never be a different symbology than the one requested.
struct CoreImageBarcodeGenerator: BarcodeGenerator {
    let symbologyKey: String
    let filterName: String
    let validator: BarcodeValidator
    /// Quiet zone added around the image, in modules. Zero when the filter already adds one.
    let quietZoneModules: CGFloat
    let configure: @Sendable (CIFilter, GenerationOptions) -> Void

    static func isFilterAvailable(_ name: String) -> Bool { CIFilter(name: name) != nil }

    func generate(_ input: String, options: GenerationOptions) throws -> CGImage {
        let payload = try validator.validate(input)
        guard let filter = CIFilter(name: filterName) else {
            throw BarcodeGenerationError.filterUnavailable(filterName)
        }
        guard let data = payload.data(using: filterName == "CICode128BarcodeGenerator" ? .ascii : .utf8) else {
            throw BarcodeValidationError.nonASCII
        }
        filter.setValue(data, forKey: "inputMessage")
        configure(filter, options)

        guard let raw = filter.outputImage else { throw BarcodeGenerationError.renderingFailed }
        var image = raw.samplingNearest()
            .transformed(by: CGAffineTransform(scaleX: options.scale, y: options.scale))

        if quietZoneModules > 0 {
            let pad = quietZoneModules * options.scale
            let canvas = image.extent.insetBy(dx: -pad, dy: -pad)
            let white = CIImage(color: .white).cropped(to: canvas)
            image = image.composited(over: white)
        }

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cg = context.createCGImage(image, from: image.extent) else {
            throw BarcodeGenerationError.renderingFailed
        }
        return cg
    }
}

private func setIfSupported(_ filter: CIFilter, _ value: Any, key: String) {
    if filter.inputKeys.contains(key) { filter.setValue(value, forKey: key) }
}

enum CoreImageGenerators {
    static func qr() -> CoreImageBarcodeGenerator {
        .init(symbologyKey: VNBarcodeSymbology.qr.rawValue, filterName: "CIQRCodeGenerator",
              validator: ByteLimitValidator(maxBytes: 2953), quietZoneModules: 4) { filter, options in
            setIfSupported(filter, options.qrCorrection.rawValue, key: "inputCorrectionLevel")
        }
    }

    static func code128() -> CoreImageBarcodeGenerator {
        .init(symbologyKey: VNBarcodeSymbology.code128.rawValue, filterName: "CICode128BarcodeGenerator",
              validator: Code128Validator(), quietZoneModules: 0) { filter, _ in
            setIfSupported(filter, 10, key: "inputQuietSpace")
        }
    }

    static func aztec() -> CoreImageBarcodeGenerator {
        .init(symbologyKey: VNBarcodeSymbology.aztec.rawValue, filterName: "CIAztecCodeGenerator",
              validator: ByteLimitValidator(maxBytes: 1914), quietZoneModules: 4) { filter, options in
            let percent = min(95, max(5, options.aztecCorrectionPercent))
            setIfSupported(filter, Float(percent), key: "inputCorrectionLevel")
        }
    }

    static func pdf417() -> CoreImageBarcodeGenerator {
        .init(symbologyKey: VNBarcodeSymbology.pdf417.rawValue, filterName: "CIPDF417BarcodeGenerator",
              validator: ByteLimitValidator(maxBytes: 1850), quietZoneModules: 4) { _, _ in }
    }

    static func dataMatrix() -> CoreImageBarcodeGenerator {
        .init(symbologyKey: VNBarcodeSymbology.dataMatrix.rawValue, filterName: "CIDataMatrixCodeGenerator",
              validator: ByteLimitValidator(maxBytes: 1556), quietZoneModules: 4) { _, _ in }
    }

    static func all() -> [CoreImageBarcodeGenerator] { [qr(), code128(), aztec(), pdf417(), dataMatrix()] }
}
