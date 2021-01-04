//
//  QuotesApp.swift
//  Quotes
//
//  Created by Todd Meng on 12/19/20.
//

import SwiftUI

@main
struct QuotesApp: App {
    var body: some Scene {
        WindowGroup {
            let quotePreview = ViewModel()
            ContentView(viewVM: quotePreview)
        }
    }
}

