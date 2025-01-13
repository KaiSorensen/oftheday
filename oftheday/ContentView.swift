import SwiftUI
import Combine


// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var viewModel: OTDViewModel
    
    // State to show/hide overlays
    @State private var showWidgetSettings = false
    @State private var showMainMenu = false
    
    var body: some View {
        NavigationView {
            HomeView(
                showWidgetSettings: $showWidgetSettings,
                showMainMenu: $showMainMenu
            )
            .navigationBarHidden(true) // We'll manage our own top bar
        }
        .overlay(
            // Widget settings overlay
            ZStack {
                if showWidgetSettings {
                    SettingsOverlay(showOverlay: $showWidgetSettings)
                }
            }
        )
        .overlay(
            // Main menu overlay
            ZStack {
                if showMainMenu {
                    MainMenuOverlay(showOverlay: $showMainMenu)
                }
            }
        )
    }
}


