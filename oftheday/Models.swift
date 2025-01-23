//
//  Untitled.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//

import SwiftUI
import BackgroundTasks

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
    var isVisible: Bool = true
    var isShuffled: Bool = false
    var notificationsOn: Bool = false
    var reactivateNotifications: Bool = false
    var notificationTime: Date?
    
    mutating func updateCurrentItem() {
        guard (items.count > 1) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Retrieve the last updated date, or default to the app start date
        let lastUpdatedKey = "lastUpdated_\(id.uuidString)"
        let defaults = UserDefaults.standard
        let lastUpdated = defaults.object(forKey: lastUpdatedKey) as? Date ?? now
        
        // Calculate the number of days that have passed
        let daysPassed = calendar.dateComponents([.day], from: lastUpdated, to: now).day ?? 0
        
        if daysPassed > 0 {
            // Increment currentItem based on the number of days passed
            currentItem = (currentItem + daysPassed) % items.count
            
            // Save the updated date
            defaults.set(now, forKey: lastUpdatedKey)
        }
    }
}

struct OTDAllLists: Codable {
    var lists: [OTDList]
    var currentList: Int = 0
    
    mutating func updateAllLists() {
        for index in 0..<lists.count {
            lists[index].updateCurrentItem()
        }
    }
}

/// ViewModel to manage an array of OTDLists
class OTDViewModel: ObservableObject {
    
    private let notificationCenter = UNUserNotificationCenter.current()

    @Published var allLists: OTDAllLists {
        didSet {
            // automatically save whenever changes are made
            saveLists()
        }
    }
    
    init() {
        self.allLists = OTDAllLists(lists: [], currentList: 0)
        
        loadLists() // Attempt to load from storage
    }
    
    /// Loads the lists from UserDefaults (if present)
    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: "OTDAllLists") {
            do {
                let decoded = try JSONDecoder().decode(OTDAllLists.self, from: data)
                self.allLists = decoded
                self.allLists.updateAllLists() // in case days have passed since last opened
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
        return list.items[list.itemOrder[list.currentItem]]
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
        guard !allLists.lists.isEmpty, allLists.currentList != -1 else {
            print("guard triggered ( nextList() )")
            return
        }
        var nextIndex = (allLists.currentList + 1) % allLists.lists.count
        while (!allLists.lists[nextIndex].isVisible) {
            nextIndex = (nextIndex + 1)
            nextIndex %= allLists.lists.count
        }
        allLists.currentList = nextIndex
        print("next list: \(nextIndex)")
    }
    
    /// Moves to the previous list (wrap around)
    func prevList() {
        let listCount = allLists.lists.count
        guard listCount > 0, allLists.currentList != -1 else {
            print("guard triggered ( prevList() )")
            return
        }
        
        var prevIndex = (allLists.currentList - 1)
        if (prevIndex < 0) {prevIndex += listCount}
        
        while (!allLists.lists[prevIndex].isVisible) {
            prevIndex = (prevIndex - 1)
            if (prevIndex < 0) {prevIndex += listCount}
        }
        
        allLists.currentList = prevIndex
        print("previous item: \(prevIndex)")
    }
    
    func addList(title: String) {
        let newList = OTDList(title: title, items: [], itemOrder: [])
        allLists.lists.append(newList)
        if (allLists.currentList == -1) {
            allLists.currentList = allLists.lists.count - 1
        }
    }
    
    func removeList(at index: Int) {
        print("list to remove ", index)
        allLists.lists[index].isVisible = false
        //there are simpler ways to write this logic, but this way is easiest for me to understand
  
        // Find another visible list to set as currentList
        if let newCurrentIndex = allLists.lists.firstIndex(where: { $0.isVisible }) {
            allLists.currentList = newCurrentIndex
            if allLists.currentList >= index {allLists.currentList -= 1}
            
        } else {
            // If no visible lists are found, set currentList to -1
            allLists.currentList = -1
        }
        
        
        print("current list after removal: ", allLists.currentList)
        
        allLists.lists.remove(at: index)
    }
    
    func moveList(from source: IndexSet, to destination: Int) {
        allLists.lists.move(fromOffsets: source, toOffset: destination)
    }
    
    func toggleShuffle() {
        allLists.lists[allLists.currentList].isShuffled.toggle()
    }
    
    /// Toggles the visibility of a specific list
    func toggleVisibility(for list: OTDList) {
        guard let index = allLists.lists.firstIndex(where: { $0.id == list.id }) else {
            print("List not found ( toggleVisibility() )")
            return }
        
        // Toggle visibility
        allLists.lists[index].isVisible.toggle()
        
        if allLists.currentList == -1 {
            allLists.currentList = index
        }
        
        // If the toggled list is the active list and it's now invisible, switch to next visible list or set to -1
        if allLists.currentList == index && !allLists.lists[index].isVisible {
            let previousIndex = allLists.currentList
            let switched = switchToNextVisible(from: previousIndex)
            if !switched {
                allLists.currentList = -1
            }
        }
    }
    /// Helper function to switch to next visible list from a given index
    private func switchToNextVisible(from index: Int) -> Bool {
        let listCount = allLists.lists.count
        var nextIndex = index
        var attempts = 0
        
        repeat {
            nextIndex = (nextIndex + 1) % listCount
            attempts += 1
            if allLists.lists[nextIndex].isVisible {
                allLists.currentList = nextIndex
                print("Switched to next visible list: \(nextIndex)")
                return true
            }
        } while (nextIndex != index) && (attempts < listCount)
        
        // No other visible list found
        return false
    }
    
    /// Notifications functions
    func enablePushNotificationsCurrentList() {
        let currentList = allLists.lists[allLists.currentList]
        guard currentList.notificationsOn,
              let notificationTime = currentList.notificationTime else {
            print("Redundancy check failed: enablePush called when notifications are off, or notificationTime is not set.")
            return
        }
        
        // Schedule the notification
        let content = UNMutableNotificationContent()
        
        // There are shorter ways to write this logic, but this is easiest to read.
        if (currentList.items[currentList.currentItem].header != nil && currentList.items[currentList.currentItem].body != nil ) {
            content.title = currentList.items[currentList.currentItem].header ?? ""
            content.body = currentList.items[currentList.currentItem].body ?? ""
        }
        else if (currentList.items[currentList.currentItem].header == nil && currentList.items[currentList.currentItem].body != nil ) {
            content.title = currentList.title
            content.body = currentList.items[currentList.currentItem].body ?? ""
        }
        else if (currentList.items[currentList.currentItem].header != nil && currentList.items[currentList.currentItem].body == nil ) {
            content.title = currentList.title
            content.body = currentList.items[currentList.currentItem].header ?? ""
        }
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.hour, .minute], from: notificationTime)
        dateComponents.timeZone = TimeZone.current
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: currentList.id.uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for list \(currentList.title).")
            }
        }
    }
        
    func disablePushNotificationsCurrentList() {
        let currentList = allLists.lists[allLists.currentList]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [currentList.id.uuidString])
        print("Notifications disabled for list \(currentList.title).")
    }
    
    // The midnight functions tell the app to update the current items when the phone's clock hits midnight, even if the app isn't open
    func scheduleMidnightUpdate() {
            let request = BGAppRefreshTaskRequest(identifier: "com.kai.oftheday")
            
            // Schedule the task to run no earlier than midnight
            let calendar = Calendar.current
            let now = Date()
            if let nextMidnight = calendar.nextDate(after: now, matching: DateComponents(hour: 14, minute: 45), matchingPolicy: .strict) {
                request.earliestBeginDate = nextMidnight
            }
            
            do {
                try BGTaskScheduler.shared.submit(request)
                print("Successfully scheduled midnight update.")
            } catch {
                print("Failed to schedule midnight update: \(error.localizedDescription)")
            }
        }

        func handleMidnightUpdate(task: BGAppRefreshTask) {
            // Schedule the next update
            scheduleMidnightUpdate()

            // Perform the update
//            allLists.updateAllLists()
            
            // this block is for testing, instead of the previous line
            
            
            for i in 0..<allLists.lists.count {
                allLists.lists[i].currentItem = (allLists.lists[i].currentItem + 1) % allLists.lists[i].items.count
            }
                
            
            
            print("Midnight update performed.")
            
            // Complete the task
            task.setTaskCompleted(success: true)
        }
    
}
