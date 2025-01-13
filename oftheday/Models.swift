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
    var header: String?
    var body: String?
    var imageName: String?  // For future image support
}

/// Represents a list of "Of The Day" items, with user settings
struct OTDList: Identifiable, Codable {
    var id = UUID()
    var title: String
    var items: [OTDItem]
    var currentItem: Int = 0
    
    // User settings
    var isShuffled: Bool = false
    var notificationsOn: Bool = false
}

struct OTDAllLists: Codable {
    var lists: [OTDList]
    var currentList: Int = 0
}

/// ViewModel to manage an array of OTDLists
class OTDViewModel: ObservableObject {
    @Published var allLists: OTDAllLists {
        didSet {
            // automatically save whenever changes are made
            saveLists()
        }
    }
    
    ///  Track which list we're on
    @Published var selectedListIndex: Int
    
    init() {
        self.allLists = OTDAllLists(lists: [], currentList: 0)
        self.selectedListIndex = 0
        
        loadLists() // Attempt to load from storage
    }
    
    /// Loads the lists from UserDefaults (if present)
    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: "OTDAllLists") {
            do {
                let decoded = try JSONDecoder().decode(OTDAllLists.self, from: data)
                self.allLists = decoded
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
            let encodedData = try JSONEncoder().encode(allLists)
            UserDefaults.standard.set(encodedData, forKey: "OTDAllLists")
        } catch {
            print("Error encoding OTDLists: \(error)")
        }
    }
    
    /// Loads sample data if no saved data is found
    private func loadSampleData() {
        self.allLists = OTDAllLists(
            lists: [
                OTDList(
                    title: "Vocabulary",
                    items: [
                        OTDItem(header: "Ubiquitous", body: "Appearing or found everywhere"),
                        OTDItem(header: "Obfuscate", body: "To make obscure or unclear")
                    ],
                    currentItem: 0
                ),
                OTDList(
                    title: "Historical People",
                    items: [
                        OTDItem(header: "Marie Curie", body: "Pioneer in radioactivity research"),
                        OTDItem(header: "Nelson Mandela", body: "Anti-apartheid revolutionary, President of South Africa")
                    ],
                    currentItem: 0
                ),
                OTDList(
                    title: "Pictures",
                    items: [
                        OTDItem(header: "Sunset", body: "A beautiful sunset picture", imageName: "sunset-sample"),
                        OTDItem(header: "Mountains", body: "Majestic mountain view", imageName: "mountain-sample")
                    ],
                    currentItem: 0
                )
            ],
            currentList: 0
        )
    }
    
    /// The currently selected list (or an empty fallback)
    var currentList: OTDList {
        return allLists.lists[allLists.currentList]
    }
    
        /// The currently selected item in `currentList`.
    var currentItem: OTDItem {
        var list = currentList
        if list.items.isEmpty {
            return OTDItem(header: "Empty", body: "No items")
        }
        
        // If the user set `isShuffled`, you could still interpret that here.
        // For now, let’s just honor the selectedItemIndex:
        if (list.currentItem < 0 || list.currentItem >= list.items.count) {list.currentItem = 0} // I'm doing this for debugging
            return list.items[list.currentItem]
        }
        
        /// Moves to the next item in the current list (wrap around)
        func nextItem() {
            let itemCount = currentList.items.count
            guard itemCount > 0 else { return }
            let nextIndex = (allLists.lists[allLists.currentList].currentItem + 1) % itemCount
            allLists.lists[allLists.currentList].currentItem = nextIndex
            print("next item: \(nextIndex)")
        }
        
        /// Moves to the previous item in the current list (wrap around)
        func prevItem() {
            let itemCount = currentList.items.count
            guard itemCount > 0 else { return }
            var prevIndex = (allLists.lists[allLists.currentList].currentItem - 1)
            if (prevIndex < 0) {prevIndex += itemCount}
            allLists.lists[allLists.currentList].currentItem = prevIndex
            print("previous item: \(prevIndex)")
        }
        
        /// Moves to the next list (wrap around)
        func nextList() {
            guard !allLists.lists.isEmpty else { return }
            let nextIndex = (allLists.currentList + 1) % allLists.lists.count
            allLists.currentList = nextIndex
            print("next list: \(nextIndex)")
            
        }
        
        /// Moves to the previous list (wrap around)
        func prevList() {
            let listCount = allLists.lists.count
            guard listCount > 0 else { return }
            var prevIndex = (allLists.currentList - 1)
            if (prevIndex < 0) {prevIndex += listCount}
            allLists.currentList = prevIndex
            print("previous item: \(prevIndex)")
        }
    
    /// Toggle shuffle for the currently selected list
    func toggleShuffle() {
        allLists.lists[allLists.currentList].isShuffled.toggle()
    }
    
    /// Reshuffle: If you track a random index, you might want to forcibly change it here
    func reshuffle() {
        print("Reshuffle pressed for list: \(currentList.title)")
    }

}
