import SwiftUI
import Combine

// MARK: - Models

/// Represents a single item in a list (header + body + optional image)
struct OTDItem: Identifiable, Codable {
    var id = UUID()
    var header: String
    var body: String
    var imageName: String?  // For future image support
}

/// Represents a list of "Of The Day" items, with user settings
struct OTDList: Identifiable, Codable {
    var id = UUID()
    var title: String
    var items: [OTDItem]
    
    // User settings
    var isShuffled: Bool = false
}

/// ViewModel to manage an array of OTDLists
class OTDViewModel: ObservableObject {
    /// The lists of items
    @Published var lists: [OTDList] = [] {
        didSet {
            saveLists()
        }
    }
    
    /// Tracks which list is selected (by index in the `lists` array).
    @Published var selectedListIndex: Int = 0
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        loadLists()  // Attempt to load from storage
    }
    
    /// Loads the lists from UserDefaults (if present)
    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: "OTDLists") {
            do {
                let decoded = try JSONDecoder().decode([OTDList].self, from: data)
                self.lists = decoded
            } catch {
                print("Error decoding OTDLists from UserDefaults: \(error)")
                loadSampleData()
            }
        } else {
            // If nothing saved, load sample data
            loadSampleData()
        }
    }
    
    /// Saves the lists to UserDefaults
    private func saveLists() {
        do {
            let encodedData = try JSONEncoder().encode(lists)
            UserDefaults.standard.set(encodedData, forKey: "OTDLists")
        } catch {
            print("Error encoding OTDLists: \(error)")
        }
    }
    
    /// Loads sample data if no saved data is found
    private func loadSampleData() {
        self.lists = [
            OTDList(
                title: "Vocabulary",
                items: [
                    OTDItem(header: "Ubiquitous", body: "Appearing or found everywhere"),
                    OTDItem(header: "Obfuscate", body: "To make obscure or unclear")
                ]
            ),
            OTDList(
                title: "Historical People",
                items: [
                    OTDItem(header: "Marie Curie", body: "Pioneer in radioactivity research"),
                    OTDItem(header: "Nelson Mandela", body: "Anti-apartheid revolutionary, President of South Africa")
                ]
            ),
            OTDList(
                title: "Pictures",
                items: [
                    OTDItem(header: "Sunset", body: "A beautiful sunset picture", imageName: "sunset-sample"),
                    OTDItem(header: "Mountains", body: "Majestic mountain view", imageName: "mountain-sample")
                ]
            )
        ]
    }
    
    /// The currently selected list
    var currentList: OTDList {
        guard lists.indices.contains(selectedListIndex) else {
            // Fallback if index is out of range
            return OTDList(title: "Empty", items: [])
        }
        return lists[selectedListIndex]
    }
    
    /// Get the item to display from the current list
    var currentItem: OTDItem {
        let list = currentList
        
        // If list is shuffled, pick a random item each time
        // Alternatively, you can track an index to rotate daily
        if list.isShuffled, !list.items.isEmpty {
            return list.items.randomElement()!
        } else {
            // For now, just show the first item
            return list.items.first ?? OTDItem(header: "Empty", body: "No items")
        }
    }
    
    /// Toggle shuffle for the currently selected list
    func toggleShuffle() {
        guard lists.indices.contains(selectedListIndex) else { return }
        lists[selectedListIndex].isShuffled.toggle()
    }
    
    /// Reshuffle: If you track a random index, you might want to forcibly change it here
    func reshuffle() {
        print("Reshuffle pressed for list: \(currentList.title)")
    }
}


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

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var viewModel: OTDViewModel
    
    @Binding var showWidgetSettings: Bool
    @Binding var showMainMenu: Bool
    
    // New state for showing the "Edit List" modal
    @State private var showEditListSheet = false
    
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
                
                // Toggle row for shuffle, [REPLACED active with edit]
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
                    
                    // Edit button (replacing the "active" button)
                    Button(action: {
                        showEditListSheet = true
                    }) {
                        // Hammer icon or another build tool icon:
                        Image(systemName: "hammer.circle")
                            .font(.title2)
                    }
                }
                .padding(.bottom, 8)
                
                // Spacer
                Spacer()
                
                // Main card display
                CardView(item: viewModel.currentItem)
                
                Spacer()
            }
        }
        // Present the edit list sheet
        .sheet(isPresented: $showEditListSheet) {
            EditListView(isPresented: $showEditListSheet, listIndex: viewModel.selectedListIndex)
                .environmentObject(viewModel)
        }
        .preferredColorScheme(.none) // Let system handle dark/light mode for now
    }
}

// MARK: - Chips Row View

struct ChipsRowView: View {
    @Binding var selectedIndex: Int
    let lists: [OTDList]
    
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

// MARK: - Card View

struct CardView: View {
    let item: OTDItem
    
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


// MARK: - Edit List View

/// A modal view (sheet) that shows all items in the selected list.
/// You can add new items, delete items, and tap to edit any item.
struct EditListView: View {
    @EnvironmentObject var viewModel: OTDViewModel
    
    /// Whether this sheet is presented
    @Binding var isPresented: Bool
    
    /// The index of the list we are editing
    var listIndex: Int
    
    // State to manage presenting the edit for a specific item
    @State private var showEditItem = false
    @State private var editingIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            if listIndex < viewModel.lists.count {
                let listTitle = viewModel.lists[listIndex].title
                
                List {
                    ForEach(Array(viewModel.lists[listIndex].items.enumerated()), id: \.1.id) { index, item in
                        // Each row: tap to edit
                        Button(action: {
                            editingIndex = index
                            showEditItem = true
                        }) {
                            VStack(alignment: .leading) {
                                Text(item.header).bold()
                                if !item.body.isEmpty {
                                    Text(item.body)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        viewModel.lists[listIndex].items.remove(atOffsets: offsets)
                    }
                }
                .navigationTitle("Edit \(listTitle)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {
                        // Create a blank item and edit it
                        let newItem = OTDItem(header: "New Item", body: "")
                        viewModel.lists[listIndex].items.append(newItem)
                        editingIndex = viewModel.lists[listIndex].items.count - 1
                        showEditItem = true
                    }) {
                        Image(systemName: "plus")
                    },
                    trailing: Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                    }
                )
                .sheet(isPresented: $showEditItem) {
                    if let index = editingIndex {
                        EditItemView(
                            item: Binding(
                                get: { viewModel.lists[listIndex].items[index] },
                                set: { viewModel.lists[listIndex].items[index] = $0 }
                            )
                        )
                    }
                }
            } else {
                Text("Invalid list index.")
                    .padding()
                    .navigationBarItems(trailing: Button("Close") {
                        isPresented = false
                    })
            }
        }
    }
}

// MARK: - Edit Item View

/// A simple view to edit one OTDItem (title + body).
/// For now, we won't worry about images; that can come later.
struct EditItemView: View {
    @Binding var item: OTDItem
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $item.header)
                }
                
                Section(header: Text("Body")) {
                    TextEditor(text: $item.body)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    // Save changes and dismiss
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "checkmark")
                }
            )
        }
    }
}
