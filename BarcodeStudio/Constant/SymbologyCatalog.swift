//
//  SymbologyCatalog.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//


import Vision

enum SymbologyCategory: String, CaseIterable, Identifiable, Sendable {
    case oneD = "1D Barcodes"
    case twoD = "2D Barcodes"
    case retail = "Retail Barcodes"
    case industrial = "Industrial Barcodes"
    case other = "Other Formats"
    var id: String { rawValue }
}

struct SymbologyReference: Sendable {
    let name: String
    let category: SymbologyCategory
    let summary: String
    let applications: String
    let dataFormat: String
}

enum SymbologyCatalog {
    static let upcAKey = "BarcodeStudio.UPCA"

    static let references: [String: SymbologyReference] = [
        VNBarcodeSymbology.qr.rawValue: .init(name: "QR Code", category: .twoD,
            summary: "Matrix code with three finder patterns and Reed-Solomon error correction (L/M/Q/H).",
            applications: "URLs, payments, tickets, Wi-Fi setup", dataFormat: "Numeric, alphanumeric, byte, kanji"),
        VNBarcodeSymbology.microQR.rawValue: .init(name: "Micro QR", category: .twoD,
            summary: "Smaller QR variant with a single finder pattern and limited capacity.",
            applications: "Small parts marking", dataFormat: "Numeric, alphanumeric, byte"),
        VNBarcodeSymbology.aztec.rawValue: .init(name: "Aztec", category: .twoD,
            summary: "Matrix code with a central bullseye finder; needs no quiet zone.",
            applications: "Boarding passes, rail tickets", dataFormat: "Text or binary"),
        VNBarcodeSymbology.dataMatrix.rawValue: .init(name: "Data Matrix", category: .industrial,
            summary: "Matrix code with an L-shaped finder pattern; compact at very small sizes.",
            applications: "Electronics, pharma and part marking", dataFormat: "Text or binary"),
        VNBarcodeSymbology.pdf417.rawValue: .init(name: "PDF417", category: .twoD,
            summary: "Stacked linear code made of multiple rows of codewords.",
            applications: "Driver licences, boarding passes", dataFormat: "Text, numeric or binary"),
        VNBarcodeSymbology.microPDF417.rawValue: .init(name: "MicroPDF417", category: .twoD,
            summary: "Compact PDF417 variant for small data.",
            applications: "Space-constrained labels", dataFormat: "Text, numeric or binary"),
        VNBarcodeSymbology.code128.rawValue: .init(name: "Code 128", category: .oneD,
            summary: "High-density linear code with code sets A, B and C and a mod-103 checksum.",
            applications: "Shipping labels, logistics", dataFormat: "Full ASCII"),
        VNBarcodeSymbology.code39.rawValue: .init(name: "Code 39", category: .industrial,
            summary: "Linear code using 43 characters and start/stop '*'; optional mod-43 check.",
            applications: "Automotive, defence, badges", dataFormat: "0-9, A-Z, - . space $ / + %"),
        VNBarcodeSymbology.code39Checksum.rawValue: .init(name: "Code 39 (Checksum)", category: .industrial,
            summary: "Code 39 with a mod-43 check character.", applications: "Industrial labelling", dataFormat: "Code 39 set"),
        VNBarcodeSymbology.code39FullASCII.rawValue: .init(name: "Code 39 Full ASCII", category: .industrial,
            summary: "Code 39 using two-character sequences to represent all ASCII.", applications: "Industrial labelling", dataFormat: "Full ASCII"),
        VNBarcodeSymbology.code39FullASCIIChecksum.rawValue: .init(name: "Code 39 Full ASCII (Checksum)", category: .industrial,
            summary: "Full ASCII Code 39 with a mod-43 check character.", applications: "Industrial labelling", dataFormat: "Full ASCII"),
        VNBarcodeSymbology.code93.rawValue: .init(name: "Code 93", category: .oneD,
            summary: "Denser successor to Code 39 with two mod-47 check characters.", applications: "Postal, logistics", dataFormat: "Full ASCII"),
        VNBarcodeSymbology.code93i.rawValue: .init(name: "Code 93i", category: .oneD,
            summary: "Vision's Code 93 variant identifier.", applications: "Logistics", dataFormat: "Full ASCII"),
        VNBarcodeSymbology.i2of5.rawValue: .init(name: "Interleaved 2 of 5", category: .industrial,
            summary: "Numeric-only code encoding digit pairs in interleaved bars and spaces.", applications: "Cartons, warehousing", dataFormat: "Even-length digit string"),
        VNBarcodeSymbology.i2of5Checksum.rawValue: .init(name: "Interleaved 2 of 5 (Checksum)", category: .industrial,
            summary: "Interleaved 2 of 5 with a check digit.", applications: "Cartons, warehousing", dataFormat: "Digits"),
        VNBarcodeSymbology.itf14.rawValue: .init(name: "ITF-14", category: .retail,
            summary: "14-digit Interleaved 2 of 5 used for GTIN-14 case packaging.", applications: "Outer cartons", dataFormat: "14 digits"),
        VNBarcodeSymbology.ean13.rawValue: .init(name: "EAN-13", category: .retail,
            summary: "13-digit retail code with a GS1 mod-10 check digit. Vision also reports UPC-A as EAN-13 with a leading 0.",
            applications: "Retail point of sale", dataFormat: "13 digits"),
        VNBarcodeSymbology.ean8.rawValue: .init(name: "EAN-8", category: .retail,
            summary: "8-digit retail code for small packages.", applications: "Small retail items", dataFormat: "8 digits"),
        VNBarcodeSymbology.upce.rawValue: .init(name: "UPC-E", category: .retail,
            summary: "Zero-suppressed 6-digit form of UPC-A.", applications: "Small retail items", dataFormat: "6 digits plus system and check digits"),
        VNBarcodeSymbology.codabar.rawValue: .init(name: "Codabar", category: .oneD,
            summary: "Numeric code with start/stop letters A-D.", applications: "Libraries, blood banks, couriers", dataFormat: "0-9 and - $ : / . +"),
        VNBarcodeSymbology.gs1DataBar.rawValue: .init(name: "GS1 DataBar", category: .retail,
            summary: "Compact GS1 linear code for GTINs.", applications: "Produce, coupons", dataFormat: "14-digit GTIN"),
        VNBarcodeSymbology.gs1DataBarExpanded.rawValue: .init(name: "GS1 DataBar Expanded", category: .retail,
            summary: "GS1 DataBar carrying application identifiers.", applications: "Weights, dates, coupons", dataFormat: "GS1 AI data"),
        VNBarcodeSymbology.gs1DataBarLimited.rawValue: .init(name: "GS1 DataBar Limited", category: .retail,
            summary: "GS1 DataBar for GTINs starting with 0 or 1.", applications: "Small items", dataFormat: "14-digit GTIN"),
    ]

    static func reference(for symbology: VNBarcodeSymbology) -> SymbologyReference {
        if let known = references[symbology.rawValue] { return known }
        let prefix = "VNBarcodeSymbology"
        var name = symbology.rawValue
        if name.hasPrefix(prefix) { name.removeFirst(prefix.count) }
        return .init(name: name, category: .other,
                     summary: "No reference text bundled for this symbology. Detection support was reported by Vision.",
                     applications: "Unknown", dataFormat: "Unknown")
    }
}
