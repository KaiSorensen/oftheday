//
//  ofthedayApp.swift
//  oftheday
//
//  Created by Kai Sorensen on 1/10/25.
//

import SwiftUI
import BackgroundTasks

@main
struct OfTheDayApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = OTDViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onAppear {
                    // Register background task to update items at midnight
                    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.kai.oftheday", using: nil) { task in
                        guard let refreshTask = task as? BGAppRefreshTask else { return }
                        viewModel.handleMidnightUpdate(task: refreshTask)
                    }
                    
                    // Schedule the first midnight update
                    viewModel.scheduleMidnightUpdate()
                }
        }
    }
}
