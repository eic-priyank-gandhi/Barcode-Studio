//
//  BarcodeResult.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//


import Vision

struct BarcodeResult: Identifiable, Sendable {
    let id = UUID()
    let payload: String?
    let symbology: VNBarcodeSymbology
    /// Vision coordinates: normalized, origin bottom-left.
    let boundingBox: CGRect
    let confidence: Float
    let date = Date()

    /// Used for duplicate suppression.
    var dedupeKey: String { symbology.rawValue + "|" + (payload ?? "<binary>") }
}

enum ScanMode: Equatable, Sendable {
    case all
    case selected(VNBarcodeSymbology)
}