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
    var itemOrder: [Int]
    var currentItem: Int = 0
    
    
    // User settings
    var isShuffled: Bool = false
    var notificationsOn: Bool = false
}

struct OTDAllLists: Codable {
    var lists: [OTDList]
    var currentList: Int = 0
    var lastUpdate: Date
}

/// ViewModel to manage an array of OTDLists
class OTDViewModel: ObservableObject {
    @Published var allLists: OTDAllLists {
        didSet {
            // automatically save whenever changes are made
            saveLists()
        }
    }
    
    init() {
        self.allLists = OTDAllLists(lists: [], currentList: 0, lastUpdate: Date())
        
        loadLists() // Attempt to load from storage
    }
    
    /// Loads the lists from UserDefaults (if present)
    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: "OTDAllLists") {
            do {
                let decoded = try JSONDecoder().decode(OTDAllLists.self, from: data)
                self.allLists = decoded
                
                //update the current items in case multiple days have passed, this might not be necessary upon midnight incrementations
                let daysPassed = 0
                for i in 0..<allLists.lists.count {
                    if (allLists.lists[i].items.count > 0) {
                        allLists.lists[i].currentItem = (allLists.lists[i].currentItem + daysPassed) % allLists.lists[i].items.count
                    }
                }
            } catch {
                print("Error decoding OTDLists from UserDefaults: \(error)")
                loadDefaults()
            }
        } else {
            // If nothing saved, load sample data
            loadDefaults()
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
    private func loadDefaults() {
        self.allLists = OTDAllLists(
            lists: [
                OTDList(
                    title: "Vocabulary",
                    items: [
                        OTDItem(header: "Ubiquitous", body: "Appearing or found everywhere"),
                        OTDItem(header: "Obfuscate", body: "To make obscure or unclear")
                    ],
                    itemOrder: [0,1],
                    currentItem: 0
                    
                ),
                OTDList(
                    title: "Historical People",
                    items: [
                        OTDItem(header: "Marie Curie", body: "Pioneer in radioactivity research"),
                        OTDItem(header: "Nelson Mandela", body: "Anti-apartheid revolutionary, President of South Africa")
                    ],
                    itemOrder: [0,1],
                    currentItem: 0
                ),
                OTDList(
                    title: "Pictures",
                    items: [
                        OTDItem(header: "Sunset", body: "A beautiful sunset picture", imageName: "sunset-sample"),
                        OTDItem(header: "Mountains", body: "Majestic mountain view", imageName: "mountain-sample")
                    ],
                    itemOrder: [0,1],
                    currentItem: 0
                )
            ],
            currentList: 0,
            lastUpdate: Date()
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
        return list.items[list.itemOrder[list.currentItem]]
    }
    
    func updateCurrents() {
        
    }
    
    func addItem(item: OTDItem) {
        // The new index is the current length of items
        let newIndex = allLists.lists[allLists.currentList].items.count

        // If it's shuffled, insert randomly; otherwise append
        if allLists.lists[allLists.currentList].isShuffled {
            let randomIndex = Int.random(in: 0...newIndex)
            // If you want to adjust currentItem here, do so carefully
            allLists.lists[allLists.currentList].itemOrder.insert(newIndex, at: randomIndex)
        } else {
            allLists.lists[allLists.currentList].itemOrder.append(newIndex)
        }

        // Now actually append the new item
        allLists.lists[allLists.currentList].items.append(item)
    }

    
    // PARAM - index of the itemOrder, not the index of the item
    func removeItem (orderIndex: Int) {
        guard (!(currentList.items.count == 0)) else {return}
        guard (!(orderIndex >= currentList.itemOrder.count)) else {return}
        
        
        // we're going to do things in order of safely (to protect against indexOutOfBounds or something, in case another thread is accessing the data concurrently)
        let itemIndex = allLists.lists[allLists.currentList].itemOrder[orderIndex]
        // decrement all item indices  above the itemIdex to avoid outOfBounds, since we're about to remove one
        let adjustedNumbers = allLists.lists[allLists.currentList].itemOrder.map { $0 > itemIndex ? $0 - 1 : $0 }
        
        //avoiding indexOutOfBounds
        if (allLists.lists[allLists.currentList].currentItem == currentList.items.count-1) {
            allLists.lists[allLists.currentList].currentItem -= 1
        }
        
        // now let's remove the itemOrder index
        allLists.lists[allLists.currentList].itemOrder = adjustedNumbers
        allLists.lists[allLists.currentList].itemOrder.remove(at: orderIndex)
        //and finally remove the item
        allLists.lists[allLists.currentList].items.remove(at: itemIndex)
        
        
    }
    
    // handles reordering of items, takes one at a time
    func moveItem(source: IndexSet, destination: Int) {
        allLists.lists[allLists.currentList].itemOrder.move(fromOffsets: source, toOffset: destination)
    }
    
    func realignItems() {
        // Ensure the current list is valid
        guard allLists.lists.indices.contains(allLists.currentList) else { return }
        
        // Reference to the current list
        let currentList = allLists.lists[allLists.currentList]
        
        // Ensure itemOrder is valid and matches the number of items
        guard currentList.itemOrder.count == currentList.items.count else {
            print("Mismatch between itemOrder and items count. Cannot realign.")
            return
        }
        
        // Create a new items array based on the order in itemOrder
        let reorderedItems = currentList.itemOrder.compactMap { index in
            // Ensure index is within bounds
            currentList.items.indices.contains(index) ? currentList.items[index] : nil
        }
        
        // Update the items array in the current list
        allLists.lists[allLists.currentList].items = reorderedItems
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
        if (allLists.lists[allLists.currentList].isShuffled) {
            realignItems()
            allLists.lists[allLists.currentList].itemOrder.shuffle()
        } else {
            allLists.lists[allLists.currentList].itemOrder.sort()
        }
    }
}
