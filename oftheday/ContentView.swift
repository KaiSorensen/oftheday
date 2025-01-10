import SwiftUI

// MARK: - Models

/// Represents a single item in a list (header + body + optional image)
struct ODTItem: Identifiable {
    let id = UUID()
    var header: String
    var body: String
    var imageName: String?  // If you want to support an image (for demonstration)
}

/// Represents a list of "Of The Day" items, with user settings
struct ODTList: Identifiable {
    let id = UUID()
    var title: String
    var items: [ODTItem]
    
    // User settings
    var isActive: Bool = true
    var isShuffled: Bool = false
}

/// ViewModel to manage an array of ODTLists
class ODTViewModel: ObservableObject {
    @Published var lists: [ODTList] = []
    
    /// Tracks which list is selected (by index in the `lists` array).
    @Published var selectedListIndex: Int = 0
    
    init() {
        // Sample data for demonstration
        self.lists = [
            ODTList(
                title: "Vocabulary",
                items: [
                    ODTItem(header: "Ubiquitous", body: "Appearing or found everywhere"),
                    ODTItem(header: "Obfuscate", body: "To make obscure or unclear")
                ]
            ),
            ODTList(
                title: "Historical People",
                items: [
                    ODTItem(header: "Marie Curie", body: "Pioneer in radioactivity research"),
                    ODTItem(header: "Nelson Mandela", body: "Anti-apartheid revolutionary, President of South Africa")
                ]
            ),
            ODTList(
                title: "Pictures",
                items: [
                    ODTItem(header: "Sunset", body: "A beautiful sunset picture", imageName: "sunset-sample"),
                    ODTItem(header: "Mountains", body: "Majestic mountain view", imageName: "mountain-sample")
                ]
            )
        ]
    }
    
    /// The currently selected list
    var currentList: ODTList {
        lists[selectedListIndex]
    }
    
    /// Get the item to display from the current list
    var currentItem: ODTItem {
        let list = currentList
        
        // If list is shuffled, pick a random item each time
        // Alternatively, you can track an index to rotate daily
        if list.isShuffled {
            return list.items.randomElement() ?? ODTItem(header: "Empty", body: "No items")
        } else {
            // For now, we'll just show the first item
            // In a real app, you'd have logic to cycle through or pick the daily item
            return list.items.first ?? ODTItem(header: "Empty", body: "No items")
        }
    }
    
    /// Toggle shuffle for the currently selected list
    func toggleShuffle() {
        lists[selectedListIndex].isShuffled.toggle()
    }
    
    /// Toggle active status for the currently selected list
    func toggleActive() {
        lists[selectedListIndex].isActive.toggle()
    }
    
    /// Reshuffle: If you track a random index, you might want to forcibly change it here
    func reshuffle() {
        // Example action: do nothing here except print
        // You might reset some daily random pick, etc.
        print("Reshuffle pressed for list: \(currentList.title)")
    }
}


// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var viewModel: ODTViewModel
    
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

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var viewModel: ODTViewModel
    
    @Binding var showWidgetSettings: Bool
    @Binding var showMainMenu: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // Top bar with widget settings & main menu
                HStack {
                    // Widget settings button (top-left)
                    Button(action: {
                        showWidgetSettings.toggle()
                    }) {
                        Image(systemName: "square.grid.2x2")
                            .font(.title3)
                    }
                    
                    Spacer()
                    
                    // Main menu button (top-right)
                    Button(action: {
                        showMainMenu.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Chips row
                ChipsRowView(selectedIndex: $viewModel.selectedListIndex, lists: viewModel.lists)
                    .padding(.vertical, 8)
                
                // Toggle row for shuffle, active, and reshuffle
                ToggleRowView()
                    .padding(.bottom, 8)
                
                // Spacer
                Spacer()
                
                // Main card display
                CardView(item: viewModel.currentItem)
                
                Spacer()
            }
        }
        .preferredColorScheme(.none) // Let system handle dark/light mode for now
    }
}

// MARK: - Chips Row View

struct ChipsRowView: View {
    @Binding var selectedIndex: Int
    let lists: [ODTList]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(lists.enumerated()), id: \.offset) { index, list in
                    Button(action: {
                        selectedIndex = index
                    }) {
                        Text(list.title)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedIndex == index ?
                                          Color.blue.opacity(0.2) :
                                          Color.gray.opacity(0.2))
                            )
                    }
                    .foregroundColor(selectedIndex == index ? .blue : .primary)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Toggle Row View

struct ToggleRowView: View {
    @EnvironmentObject var viewModel: ODTViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            // Shuffle Toggle
            Button(action: {
                viewModel.toggleShuffle()
            }) {
                Image(systemName: viewModel.currentList.isShuffled ? "shuffle.circle.fill" : "shuffle.circle")
                    .font(.title2)
            }
            
            // Reshuffle Button
            Button(action: {
                viewModel.reshuffle()
            }) {
                Image(systemName: "arrow.clockwise.circle")
                    .font(.title2)
            }
            
            // Active Toggle
            Button(action: {
                viewModel.toggleActive()
            }) {
                Image(systemName: viewModel.currentList.isActive ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title2)
            }
        }
    }
}

// MARK: - Card View

struct CardView: View {
    let item: ODTItem
    
    var body: some View {
        VStack(spacing: 16) {
            Text(item.header)
                .font(.headline)
                .padding(.horizontal)
            
            if let imageName = item.imageName,
               let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(8)
            }
            
            Text(item.body)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(color: .black.opacity(0.1), radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - Overlays

struct SettingsOverlay: View {
    @Binding var showOverlay: Bool
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss overlay if tapped outside
                    showOverlay = false
                }
            
            // Overlay container
            VStack {
                Text("Widget Settings")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Placeholder for future widget settings
                Text("Configure widget options here…")
                    .padding()
                
                Spacer()
                
                Button("Close") {
                    showOverlay = false
                }
                .padding()
            }
            .frame(maxWidth: 300, maxHeight: 300)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

struct MainMenuOverlay: View {
    @Binding var showOverlay: Bool
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss overlay if tapped outside
                    showOverlay = false
                }
            
            // Overlay container
            VStack {
                Text("Main Menu")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Placeholder for future app/account settings
                Text("App and account settings go here…")
                    .padding()
                
                Spacer()
                
                Button("Close") {
                    showOverlay = false
                }
                .padding()
            }
            .frame(maxWidth: 300, maxHeight: 300)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}
