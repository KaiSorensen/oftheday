import SwiftUI
import BackgroundTasks
import UserNotifications


/// ViewModel to manage an array of OTDLists
class OTDViewModel: ObservableObject {
    
    //consider making this a static global variable
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
        if let userDefaults = UserDefaults(suiteName: "group.com.kai.oftheday"),
           let data = userDefaults.data(forKey: "OTDAllLists") {
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
        if let userDefaults = UserDefaults(suiteName: "group.com.kai.oftheday") {
            do {
                let encodedData = try JSONEncoder().encode(allLists)
                userDefaults.set(encodedData, forKey: "OTDAllLists")
                print("✅ Data Found in UserDefaults")
            } catch {
                print("❌ No Data Found in UserDefaults")
            }
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
                        OTDItem(header: "Sunset", body: "A beautiful sunset picture", imageReference: "sunset-sample"),
                        OTDItem(header: "Mountains", body: "Majestic mountain view", imageReference: "mountain-sample")
                    ],
                    itemOrder: [0,1],
                    currentItem: 0
                )
            ],
            currentList: 0
        )
    }
    
    // ?? currentList/Item should return indices, not values. This is annoying as shit.
    /// The currently selected list (or an empty fallback)
    var currentList: OTDList {
        return allLists.lists[allLists.currentList]
    }
    
    /// The currently selected item in currentList.
    var currentItem: OTDItem {
        var list = currentList
        if list.items.isEmpty {
            return OTDItem(header: "Empty", body: "No items")
        }
        
        if (list.currentItem < 0 || list.currentItem >= list.items.count) {
            // Just a safety fallback
            list.currentItem = 0
        }
        return list.items[list.itemOrder[list.currentItem]]
    }

    func addItem(item: OTDItem) {
        print("addingItem")
        item.printItem()
        let newIndex = allLists.lists[allLists.currentList].items.count
        
        if allLists.lists[allLists.currentList].isShuffled {
            let randomIndex = Int.random(in: 0...newIndex)
            allLists.lists[allLists.currentList].itemOrder.insert(newIndex, at: randomIndex)
        } else {
            allLists.lists[allLists.currentList].itemOrder.append(newIndex)
        }
        
        allLists.lists[allLists.currentList].items.append(item)
        if allLists.lists[allLists.currentList].currentItem == -1 {
            allLists.lists[allLists.currentList].currentItem = 0
        }
    }
    
    // PARAM - index of the itemOrder, not the index of the item
    func removeItem (orderIndex: Int) {
        guard !(currentList.items.count == 0) else { return }
        guard !(orderIndex >= currentList.itemOrder.count) else { return }
        
        let itemIndex = allLists.lists[allLists.currentList].itemOrder[orderIndex]
        
        let adjustedNumbers = allLists.lists[allLists.currentList].itemOrder.map { $0 > itemIndex ? $0 - 1 : $0 }
        
        if (allLists.lists[allLists.currentList].currentItem == currentList.items.count - 1) {
            allLists.lists[allLists.currentList].currentItem -= 1
        }
        
        allLists.lists[allLists.currentList].itemOrder = adjustedNumbers
        allLists.lists[allLists.currentList].itemOrder.remove(at: orderIndex)
        allLists.lists[allLists.currentList].items.remove(at: itemIndex)
        
        if (allLists.lists[allLists.currentList].items.isEmpty) {
            allLists.lists[allLists.currentList].disableNotifications()
            allLists.lists[allLists.currentList].notificationsOn = false
        }
    }
    
    // handles reordering of items, takes one at a time
    func moveItem(source: IndexSet, destination: Int) {
        allLists.lists[allLists.currentList].itemOrder.move(fromOffsets: source, toOffset: destination)
    }
    
    func updateItem(at orderIndex: Int, with item: OTDItem) {
        guard allLists.lists.indices.contains(allLists.currentList),
              allLists.lists[allLists.currentList].itemOrder.indices.contains(orderIndex) else { return }
        
        let itemIndex = allLists.lists[allLists.currentList].itemOrder[orderIndex]
        allLists.lists[allLists.currentList].items[itemIndex] = item
    }
    
    func realignItems() {
        guard allLists.lists.indices.contains(allLists.currentList) else {
            print("Guard triggered ( realignItems() )")
            return
        }
        
        let cList = allLists.lists[allLists.currentList]
        guard cList.itemOrder.count == cList.items.count else {
            print("Mismatch between itemOrder and items count. Cannot realign.")
            return
        }
        
        let reorderedItems = cList.itemOrder.compactMap { index in
            cList.items.indices.contains(index) ? cList.items[index] : nil
        }
        
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
        if (prevIndex < 0) { prevIndex += itemCount }
        allLists.lists[allLists.currentList].currentItem = prevIndex
        print("previous item: \(prevIndex)")
    }
    
    // returns the previous image (even if it was nil, as that's important info for maintaining the image table)
    @discardableResult
    func addItemImage(at orderIndex: Int, with imageRef: String) -> String? {
        guard allLists.lists.indices.contains(allLists.currentList),
              allLists.lists[allLists.currentList].itemOrder.indices.contains(orderIndex) else {
            print ("guard triggered at addItemImage()")
            return nil
        }
        
        let itemIndex = allLists.lists[allLists.currentList].itemOrder[orderIndex]
        let oldImage = allLists.lists[allLists.currentList].items[itemIndex].imageReference
        allLists.lists[allLists.currentList].items[itemIndex].imageReference = imageRef
        
        return oldImage // might be nil
    }
    
    func removeItemImage(at orderIndex: Int) {
        guard allLists.lists.indices.contains(allLists.currentList),
              allLists.lists[allLists.currentList].itemOrder.indices.contains(orderIndex) else { return }
        
        let itemIndex = allLists.lists[allLists.currentList].itemOrder[orderIndex]
        allLists.lists[allLists.currentList].items[itemIndex].imageReference = nil
    }
    // returns a list of imageReferences to be decremented if necessary (in the case that duplicates were added, we'll later offset its increment)
    @discardableResult
    func addListImage(imageRef: String) -> String? {
        // Check for duplicate
        if (currentList.imageReferences.contains(imageRef)) {
            print("found duplicate - addListImage()")
            return imageRef
        } else {
            allLists.lists[allLists.currentList].imageReferences.append(imageRef)
            return nil
        }
    }
    
    func removeListImage(imageRef: String) {
        allLists.lists[allLists.currentList].imageReferences.removeAll(where: {$0 == imageRef})
    }
    func removeAllListImages () {
        // Swift will handle the freeing :)
        allLists.lists[allLists.currentList].imageReferences = []
    }
    
    func openListItem(listUUID: UUID, itemUUID: UUID) {
        // Find which list has this UUID
        guard let listIndex = allLists.lists.firstIndex(where: { $0.id == listUUID }) else {
            print("list not found ( openList() )")
            return
        }
        // Switch to that list
        allLists.currentList = listIndex
        // Switch to the correct item
        guard let itemIndex = currentList.items.firstIndex(where: { $0.id == itemUUID }) else {
            print("item not found ( openList() )")
            return
        }
        allLists.lists[listIndex].currentItem = itemIndex
        
        print("Switched to list \(listIndex) and item \(itemIndex)")
    }
    
    /// Moves to the next list (wrap around)
    func nextList() {
        guard !allLists.lists.isEmpty, allLists.currentList != -1 else {
            print("guard triggered ( nextList() )")
            return
        }
        var nextIndex = (allLists.currentList + 1) % allLists.lists.count
        while (!allLists.lists[nextIndex].isVisible) {
            nextIndex = (nextIndex + 1) % allLists.lists.count
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
        if (prevIndex < 0) { prevIndex += listCount }
        
        while (!allLists.lists[prevIndex].isVisible) {
            prevIndex = (prevIndex - 1)
            if (prevIndex < 0) { prevIndex += listCount }
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
        allLists.lists[index].disableNotifications() // I don't want to know what happens if I don't do this. We'll find out in post-testing.
        
        
        // If a list is removed while notifications are on, disable them
        if allLists.lists[index].notificationsOn {
            allLists.lists[index].disableNotifications()
        }
  
        if let newCurrentIndex = allLists.lists.firstIndex(where: { $0.isVisible }) {
            allLists.currentList = newCurrentIndex
            if allLists.currentList >= index {
                allLists.currentList -= 1
            }
        } else {
            allLists.currentList = -1
        }
        
        print("current list after removal: ", allLists.currentList)
        allLists.lists.remove(at: index)
    }
    
    func moveList(from source: IndexSet, to destination: Int) {
        allLists.lists.move(fromOffsets: source, toOffset: destination)
        
        let sourceIndex = source.first!
        let destinationIndex = (destination > sourceIndex) ? (destination - 1) : destination
        
        print("move src/dst ", sourceIndex, "/", destinationIndex, "  --  curr ", allLists.currentList)
        
        if allLists.currentList == -1 { return }
        
        // If the moved list is the currentList
        if (allLists.currentList == sourceIndex) {
            print("moved currentList")
            allLists.currentList = destinationIndex
        }
        /* If the currentList's index changed:
         if the currentList index is between (inclusive) the source and destination
         there are two 'between' scenatios: it's between when source>destination, or it's between when destination>source
        */
        else if (allLists.currentList <= destinationIndex && allLists.currentList >= sourceIndex ||
                 allLists.currentList >= destinationIndex && allLists.currentList <= sourceIndex) {
            print("incrementing current list")
            if (sourceIndex > destinationIndex) {
                // the item was moved up
                allLists.currentList += 1
            } else if (sourceIndex < destinationIndex) {
                // the item was moved down
                allLists.currentList -= 1
            }
        }
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
    
    // MARK: - Refactored toggleVisibility
    
    /// Toggles the visibility of a specific list, and handles notifications properly.
    func toggleVisibility(for list: OTDList) {
        guard let index = allLists.lists.firstIndex(where: { $0.id == list.id }) else {
            print("List not found in toggleVisibility()")
            return
        }
        
        // Flip isVisible
        allLists.lists[index].isVisible.toggle()
        
        // If we’re hiding the list, disable notifications if they were on
        if !allLists.lists[index].isVisible {
            if allLists.lists[index].notificationsOn {
                allLists.lists[index].disableNotifications()
            }
        }
        // If we’re making the list visible again and notificationsOn is true, re-enable them
        else {
            if allLists.lists[index].notificationsOn {
                allLists.lists[index].enableNotifications()
            }
        }

        // If no list is currently selected, pick this one as the new current if we just made it visible
        if allLists.currentList == -1, allLists.lists[index].isVisible {
            allLists.currentList = index
        }
        
        // If the toggled list was active, but we just made it invisible, move to the next visible list
        if allLists.currentList == index && !allLists.lists[index].isVisible {
            let switched = switchToNextVisible(from: index)
            if !switched {
                // If we fail to find another visible list
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

    // The midnight functions tell the app to update the current items
    // when the phone's clock hits midnight, even if the app isn't open
    func scheduleMidnightUpdate() {
        let request = BGAppRefreshTaskRequest(identifier: "com.kai.oftheday")
        
        // Example here: set earliestBeginDate to tomorrow at a specific time (or midnight, etc.)
        let calendar = Calendar.current
        let now = Date()
        if let nextMidnight = calendar.nextDate(after: now,
                                                matching: DateComponents(hour: 0, minute: 0),
                                                matchingPolicy: .strict) {
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
        // Re-schedule next update
        scheduleMidnightUpdate()

        // Example midnight logic: simply increment each list’s currentItem
        for i in 0..<allLists.lists.count {
            let count = allLists.lists[i].items.count
            if count > 0 {
                allLists.lists[i].currentItem = (allLists.lists[i].currentItem + 1) % count
            }
        }
        
        print("Midnight update performed.")
        task.setTaskCompleted(success: true)
    }
}
