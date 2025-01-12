//
//  ofthedayApp.swift
//  oftheday
//
//  Created by user268370 on 1/10/25.
//

import SwiftUI

@main
struct OfTheDayApp: App {
    @StateObject private var viewModel = OTDViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
