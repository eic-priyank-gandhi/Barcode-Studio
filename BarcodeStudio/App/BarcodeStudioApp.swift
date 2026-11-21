//
//  BarcodeStudioApp.swift
//  BarcodeStudio
//
//  Created by Priyank Gandhi on 01/11/26.
//

import SwiftUI

@main
struct BarcodeStudioApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

struct RootView: View {
    
    var body: some View {
        TabView {
            NavigationStack {
                SymbologiesView()
            }
            .tabItem {
                Label("Symbologies", systemImage: "list.bullet.rectangle")
            }
            
            NavigationStack {
                ScannerView()
            }
            .tabItem {
                Label("Scanner", systemImage: "barcode.viewfinder")
            }
            
            NavigationStack {
                GeneratorView()
            }
            .tabItem {
                Label("Generator", systemImage: "list.bullet.rectangle")
            }
        }
    }
}
