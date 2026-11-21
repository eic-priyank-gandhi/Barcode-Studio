//
//  PreviewView.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 02/11/26.
//

import AVFoundation
import SwiftUI

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    private var boxes: [CAShapeLayer] = []

    var previewLayer: AVCaptureVideoPreviewLayer? { layer as? AVCaptureVideoPreviewLayer }

    func update(with results: [BarcodeResult]) {
        boxes.forEach { $0.removeFromSuperlayer() }
        boxes = []
        guard let previewLayer else { return }
        for result in results {
            // Vision: origin bottom-left. Metadata output rect: origin top-left.
            let b = result.boundingBox
            let metadataRect = CGRect(x: b.minX, y: 1 - b.maxY, width: b.width, height: b.height)
            let rect = previewLayer.layerRectConverted(fromMetadataOutputRect: metadataRect)
            let shape = CAShapeLayer()
            shape.path = UIBezierPath(roundedRect: rect, cornerRadius: 6).cgPath
            shape.strokeColor = UIColor.systemGreen.cgColor
            shape.fillColor = UIColor.systemGreen.withAlphaComponent(0.12).cgColor
            shape.lineWidth = 3
            layer.addSublayer(shape)
            boxes.append(shape)
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    let results: [BarcodeResult]

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer?.session = session
        view.previewLayer?.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ view: PreviewView, context: Context) {
        view.update(with: results)
    }
}
