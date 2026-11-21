# Barcode Studio

iOS application to explore barcodes, scan barcodes, and generate them using Swift, SwiftUI, Vision, and Core Image.

Intended for colleagues and newcomers interested in learning about different kinds of barcodes at their own pace.

Features include:

• **Symbologies**: List of all barcodes supported by Vision, with search, categories, and explanations.

• **Scanner**: Live camera feed, bounding box overlay and list of detected barcodes. Can scan any barcode type or specific symbologies.

• **Generator**: Ability to generate a QR, Code 128, Aztec, PDF417, and Data Matrix barcodes. Image sharing.

Quickstart guide
• Open BarcodeStudio.xcodeproj in Xcode.
• Pick your own signing team (Bundle Identifier might require changes too).
• Run the project on an actual device since Simulator cannot use the camera. Only Symbologies and Generator work there.
• Authorise Barcode Studio to access the camera when prompted.

Third-party dependencies? None at all. Minimum deployment target iOS 27.0, adjust accordingly.

Explore features
Step Action Location to check documentation
1 Navigate around Open every screen, explore search and categorisation functionalities. Constant/SymbologyCatalog.swift
2 Scan barcodes Scan a product/barcode/label. Tap Scan This Symbology under Symbologies list. Services/VisionBarcodeScanner.swift, Features/Scanner/
3 Generate barcodes Generate QR/Code 128/Aztec/PDF417/DataMatrix and scan them. Incorrect inputs cause validation errors. Validator/, Features/Generator/
4 Expand functionality Create additional generators or implement scanner from pictures. Services/
Project directory structure
BarcodeStudio/
├── App/            Main file and Tab Bar Controller.
├── Models/         Models for Symbologies and Scans.
├── Constant/       Symbology catalog and error messages.
├── Services/       Barcodes scanner, Symbology catalogue manager, Generators registry.
├── Validator/      Validators and Code 128 encoder.
├── Features/       Symbologies, Scanner and Generator screens implementations.
└── GenericView/    UI Components.

Interesting facts
• Catalogue of available Symbologies is generated dynamically at runtime by Vision framework.
• Barcode scanning processes specific types internally in Vision for efficiency purposes.
• Vision recognises UPC-A barcodes as EAN-13 barcodes prepending the zero.
Current limitations and upcoming enhancements
Pending implementation: EAN/UPC/Code 39 generators, Scanner feature to detect codes within picture, History saving options, Unit testing.
