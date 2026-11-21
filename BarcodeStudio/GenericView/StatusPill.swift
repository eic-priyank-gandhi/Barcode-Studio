//
//  StatusPill.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import SwiftUI

struct StatusPill: View {
    let label: String
    let on: Bool
    var body: some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(on ? Color.green.opacity(0.2) : Color.secondary.opacity(0.15), in: Capsule())
            .foregroundStyle(on ? Color.green : Color.secondary)
            .accessibilityLabel("\(label): \(on ? "supported" : "not supported")")
    }
}
