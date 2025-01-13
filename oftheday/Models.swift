//
//  Untitled.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//

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
    @Published var lists: [OTDList] = [] {
        didSet {
            saveLists()
            // After loading/saving, ensure we keep our array of item indices in sync
            ensureSelectedItemIndices()
        }
    }
    
    /// Tracks which list is selected (by index in the `lists` array).
    @Published var selectedListIndex: Int = 0 {
        didSet {
            // Reset item index (optional) OR keep the item index from before,
            // depending on how you want the UX. For now, let's keep it.
            ensureSelectedItemIndices()
        }
    }
    
    /// For each list, track the currently selected item index.
    /// This lets us remember the user's position in every list individually.
    @Published var selectedItemIndices: [Int] = []
    
    init() {
        loadLists() // Attempt to load from storage
        ensureSelectedItemIndices()
    }
    
    private func ensureSelectedItemIndices() {
        // Make sure the array has the same count as `lists`.
        if selectedItemIndices.count < lists.count {
            // Add zeros for any missing lists
            selectedItemIndices.append(contentsOf: Array(
                repeating: 0,
                count: lists.count - selectedItemIndices.count
            ))
        } else if selectedItemIndices.count > lists.count {
            // If we have more entries than lists (e.g. user deleted some),
            // trim the array.
            selectedItemIndices = Array(selectedItemIndices.prefix(lists.count))
        }
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
    
    /// The currently selected list (or an empty fallback)
        var currentList: OTDList {
            guard lists.indices.contains(selectedListIndex) else {
                return OTDList(title: "Empty", items: [])
            }
            return lists[selectedListIndex]
        }
        
        /// The currently selected item in `currentList`.
        var currentItem: OTDItem {
            let list = currentList
            if list.items.isEmpty {
                return OTDItem(header: "Empty", body: "No items")
            }
            
            // If the user set `isShuffled`, you could still interpret that here.
            // For now, let’s just honor the selectedItemIndex:
            let index = selectedItemIndices[selectedListIndex]
            return list.items[index]
        }
        
        /// Moves to the next item in the current list (wrap around)
        func nextItem() {
            let itemCount = currentList.items.count
            guard itemCount > 0 else { return }
            selectedItemIndices[selectedListIndex] = (selectedItemIndices[selectedListIndex] + 1) % itemCount
        }
        
        /// Moves to the previous item in the current list (wrap around)
        func prevItem() {
            let itemCount = currentList.items.count
            guard itemCount > 0 else { return }
            let newIndex = (selectedItemIndices[selectedListIndex] - 1 + itemCount) % itemCount
            selectedItemIndices[selectedListIndex] = newIndex
        }
        
        /// Moves to the next list (wrap around)
        func nextList() {
            guard !lists.isEmpty else { return }
            selectedListIndex = (selectedListIndex + 1) % lists.count
        }
        
        /// Moves to the previous list (wrap around)
        func prevList() {
            guard !lists.isEmpty else { return }
            let newIndex = (selectedListIndex - 1 + lists.count) % lists.count
            selectedListIndex = newIndex
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
