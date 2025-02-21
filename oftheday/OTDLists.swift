//
//  OTDLists.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/19/25.
//

import UserNotifications

struct NotificationHelper {
    static let notificationCenter = UNUserNotificationCenter.current()
}


// MARK: - OTDItem

/// Represents a single item in a list (header + body + optional image)
struct OTDItem: Identifiable, Codable, Equatable {
    // meta data
    var id = UUID()
    var dateCreated = Date()
    var dateModified = Date()
    
    // data
    var header: String?
    var body: String?
    
    var isEmpty: Bool {
        header == nil && body == nil
    }
    
    mutating func updateHeader(_ newHeader: String?) {
        self.header = newHeader
        self.dateModified = Date()
    }
    mutating func updateBody(_ newBody: String?) {
        self.body = newBody
        self.dateModified = Date()
    }
    
    func printItem() {
        print("Item:")
        if let h = header {
            print("header: ", h)
        }
        if let b = body {
            print("body: ", b)
        }
    }
}

// MARK: - OTDListItems

struct OTDListItems: Codable {
    var items: [OTDItem] = []
    var itemOrder: [Int] = []
    var currentItemIndex: Int = -1
    
    
    // some extra metadata
    var order: String = "custom"
    
    // ITEM ORDER FUNCTIONS
    mutating func restoreOrder() {
        itemOrder = itemOrder.sorted()
        order = "custom"
    }
    mutating func shuffleItems() {
        itemOrder.shuffle()
        order = "shuffled"
    }
    mutating func sortAlphabeticallyByHeader() {
        itemOrder = itemOrder.sorted { (i1, i2) -> Bool in
            guard let h1 = self.items[i1].header, let h2 = self.items[i2].header else {
                return false
            }
            return h1 < h2
        }
        order = "alpha"
    }
    mutating func sortByDateNewFirst() {
        itemOrder = itemOrder.sorted { (i1, i2) -> Bool in
            let d1 = self.items[i1].dateCreated
            let d2 = self.items[i2].dateCreated
            return d1 < d2
        }
        order = "date-new-first"
    }
    mutating func sortByDateOldFirst() {
        itemOrder = itemOrder.sorted { (i1, i2) -> Bool in
            let d1 = self.items[i1].dateCreated
            let d2 = self.items[i2].dateCreated
            return d1 > d2
        }
        order = "date-old-first"
    }
    
    mutating func addItem(_ item: OTDItem) {
        let newIndex = itemOrder.count
        
        switch order {
        case "custom":
            itemOrder.append(newIndex)
        case "shuffled":
            let randomIndex = Int.random(in: 0...newIndex)
            itemOrder.insert(newIndex, at: randomIndex)
        case "alpha":
            itemOrder.append(newIndex)
        case "date-new-first":
            itemOrder.insert(newIndex, at: 0)
        case "date-old-first":
            itemOrder.insert(newIndex, at: itemOrder.count)
        default:
            return
        }
        
        items.append(item)
        // no better way than O(n) without excess complexity
        if (order == "alpha") {
            sortAlphabeticallyByHeader()
        }
        if (currentItemIndex == -1) {
            currentItemIndex = 0
        }
    }
    
    mutating func removeItem(_ index: Int) {
        guard index >= 0 && index < itemOrder.count else {
            print("called removeItem() on invalid index")
            return
        }
        let itemIndex = itemOrder[index]
        if currentItemIndex >= itemIndex {
            currentItemIndex -= 1
        }
        
        //decrement all greater indices in itemOrder
        for i in 0..<itemOrder.count {
            if itemOrder[i] > index {
                itemOrder[i] -= 1
            }
        }
        itemOrder.remove(at: index)
        items.remove(at: itemIndex)
    }
    
    mutating func setItem(_ item: OTDItem, at index: Int) {
        guard index >= 0 && index < itemOrder.count else {
            print("called setItem() on invalid index")
            return
        }
        let itemIndex = itemOrder[index]
        items[itemIndex] = item
    }
    
    mutating func moveItem(from source: IndexSet, to destination: Int) {
        itemOrder.move(fromOffsets: source, toOffset: destination)
    }
    
    func getCurrentItem() -> OTDItem? {
        guard !items.isEmpty else { return nil }
        let currentIndex = itemOrder[currentItemIndex]
        return items[currentIndex]
    }
    
    mutating func setCurrentItem(_ index: Int) {
        guard(index >= 0 && index < itemOrder.count) else {
            print(#function + " called with invalid index")
            return
        }
        currentItemIndex = index
    }
    
    mutating func nextItem() -> OTDItem? {
        currentItemIndex = (currentItemIndex + 1) % itemOrder.count
        print("next item index: \(currentItemIndex)")
        return items[itemOrder[currentItemIndex]]
    }
    
    mutating func prevItem() -> OTDItem? {
        currentItemIndex = (currentItemIndex - 1 + itemOrder.count) % itemOrder.count
        print("prev item index: \(currentItemIndex)")
        return items[itemOrder[currentItemIndex]]
    }
}

// MARK: - OTDListMetadata

/// Represents a list of "Of The Day" items, with user settings
struct OTDListMetadata: Identifiable, Codable, Equatable {
    // meta-metadata
    var id = UUID()
    var dateCreated = Date()
    var dateModified = Date()
    
    // the list's metadata
    var owner: UUID
    var itemsID: String = ""
    var isEmpty: Bool = false
    
    var title: String
    var today: Bool = false
    var isPublic: Bool = false
    var notificationsOn: Bool = false
    
    // functional data
//    var currentItemIndex: Int = 0
    var notificationTime: Date?
    
    // Image
    var listImage: String? = nil
    var underlayImage: Bool = false // if the user wants the image to appear underneath items
        
//    /// Schedules a daily notification for this list’s current item, if notificationsOn == true and list is visible.
//    /// We pass in the notification center from outside for clarity.
//    mutating func enableNotifications() {
//        guard notificationsOn, !items.isEmpty, let notificationTime = notificationTime else {
//            return
//        }
//        
//        // Remove any existing notifications for this list
//        disableNotifications()
//        
//        let content = UNMutableNotificationContent()
//        
//        print("enabling notifs for item", currentItem)
//        
//        let currentTitle = title
//        let currentHeader = items[currentItem].header
//        let currentBody = items[currentItem].body
//        
//        // Configure notification content
//        switch (currentHeader, currentBody) {
//        case let (h?, b?):
//            content.title = h
//            content.body  = b
//        case (nil, let b?):
//            content.title = currentTitle
//            content.body  = b
//        case (let h?, nil):
//            content.title = currentTitle
//            content.body  = h
//        default:
//            content.title = currentTitle
//            content.body  = "No content available."
//        }
//        
//        // saving the current item/list so pressing the notification can open back to it later
//        content.userInfo = [
//            "listIDstring": id.uuidString,
//            "itemIDstring": items[currentItem].id.uuidString
//        ]
//        
//        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
//        dateComponents.timeZone = TimeZone.current
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
//        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
//        
//        // Use the static notificationCenter
//        NotificationHelper.notificationCenter.add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error.localizedDescription)")
//            } else {
//                print("Notification scheduled for list \(currentTitle)")
//            }
//        }
//    }
//    
//    // ?? used inside function, this is stupid code, please find a better way
//    mutating func disableNotifications() {
//        NotificationHelper.notificationCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
//        print("Notifications disabled for list \(title)")
//    }
//    
//    /// Removes pending notifications for this list
//    mutating func disableNotifications(using notificationCenter: UNUserNotificationCenter) {
//        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
//        print("Notifications disabled for list \(title)")
//    }
}






import BackgroundTasks

// MARK: - OTDListModel


/// ViewModel to manage an array of OTDLists
class OTDListModel: ObservableObject {
    
    @Published var metadata: OTDListMetadata
    @Published var listItems: OTDListItems?
    
    init(metadata: OTDListMetadata) {
        self.metadata = metadata
        loadListItems() // !! this is the least efficient line in my app
    }
    
    /// Loads the lists from UserDefaults (if present)
    private func loadListItems() {
        do {
            let data = UserDefaults(suiteName: diskGroup)?.data(forKey: metadata.itemsID)
            let listItemsFound = try JSONDecoder().decode(OTDListItems.self, from: data!)
            listItems = listItemsFound
        }
        catch {
            print("catastrophic error in loading list: ", metadata.title)
        }
    }
    
    /// Saves the lists to UserDefaults
    private func saveList() {
        if let userDefaults = UserDefaults(suiteName: diskGroup) {
            do {
                let encodedData = try JSONEncoder().encode(listItems)
                userDefaults.set(encodedData, forKey: metadata.itemsID)
                print("✅ Data Found in UserDefaults")
            } catch {
                print("Catastrophic error in saving list: ", metadata.title)
            }
        }
    }
    
    func getCurrentItem() -> OTDItem? {
        return listItems!.getCurrentItem()
    }
    
    func addItem(item: OTDItem) {
        listItems!.addItem(item)
        metadata.dateModified = Date()
        saveList()
    }
    func setItem(at orderIndex: Int, with item: OTDItem) {
        listItems!.setItem(item, at: orderIndex)
    }
    
    // PARAM - index of the itemOrder, not the index of the item
    func removeItem (orderIndex: Int) {
        listItems!.removeItem(orderIndex)
        metadata.dateModified = Date()
        saveList()
    }
    
    // handles reordering of items, takes one at a time
    func moveItem(source: IndexSet, destination: Int) {
        listItems!.moveItem(from: source, to: destination)
        saveList()
    }
    
    
    
    
    /// Moves to the next item in the current list (wrap around)
    func nextItem() -> OTDItem? {
        let nextItem: OTDItem? = listItems!.nextItem()
        return nextItem
    }
    
    /// Moves to the previous item in the current list (wrap around)
    func prevItem() -> OTDItem? {
        let prevItem: OTDItem? = listItems!.prevItem()
        return prevItem
    }
    
//    // returns the previous image (even if it was nil, as that's important info for maintaining the image table)
//    @discardableResult
//    func addItemImage(at orderIndex: Int, with imageRef: String) -> String? {
//        guard allLists.lists.indices.contains(allLists.currentList),
//              allLists.lists[allLists.currentList].itemOrder.indices.contains(orderIndex) else {
//            print ("guard triggered at addItemImage()")
//            return nil
//        }
//        
//        let itemIndex = allLists.lists[allLists.currentList].itemOrder[orderIndex]
//        let oldImage = allLists.lists[allLists.currentList].items[itemIndex].imageReference
//        allLists.lists[allLists.currentList].items[itemIndex].imageReference = imageRef
//        
//        return oldImage // might be nil
//    }
    
//    func removeItemImage(at orderIndex: Int) {
//        guard allLists.lists.indices.contains(allLists.currentList),
//              allLists.lists[allLists.currentList].itemOrder.indices.contains(orderIndex) else { return }
//        
//        let itemIndex = allLists.lists[allLists.currentList].itemOrder[orderIndex]
//        allLists.lists[allLists.currentList].items[itemIndex].imageReference = nil
//    }
//    // returns a list of imageReferences to be decremented if necessary (in the case that duplicates were added, we'll later offset its increment)
    
    func setListImage(imageRef: String) {
        metadata.listImage = imageRef
    }
    
    func removeListImage(imageRef: String) {
        guard let img = metadata.listImage else {
            print("called removeListImage() but metadata.listImage was nil")
            return
        }
        ImageTable.imageTable.removeImage(for: img)
        metadata.listImage = nil
        metadata.underlayImage = false
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // The midnight functions tell the app to update the current items
    // when the phone's clock hits midnight, even if the app isn't open
//    func scheduleMidnightUpdate() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.kai.oftheday")
//        
//        // Example here: set earliestBeginDate to tomorrow at a specific time (or midnight, etc.)
//        let calendar = Calendar.current
//        let now = Date()
//        if let nextMidnight = calendar.nextDate(after: now,
//                                                matching: DateComponents(hour: 0, minute: 0),
//                                                matchingPolicy: .strict) {
//            request.earliestBeginDate = nextMidnight
//        }
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//            print("Successfully scheduled midnight update.")
//        } catch {
//            print("Failed to schedule midnight update: \(error.localizedDescription)")
//        }
//    }
//    
//    func handleMidnightUpdate(task: BGAppRefreshTask) {
//        // Re-schedule next update
//        scheduleMidnightUpdate()
//        
//        // Example midnight logic: simply increment each list’s currentItem
//        for i in 0..<allLists.lists.count {
//            let count = allLists.lists[i].items.count
//            if count > 0 {
//                allLists.lists[i].currentItem = (allLists.lists[i].currentItem + 1) % count
//            }
//        }
//        
//        print("Midnight update performed.")
//        task.setTaskCompleted(success: true)
//    }
}
