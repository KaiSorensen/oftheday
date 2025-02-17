//
//  NotificationHelper.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/16/25.
//

import UserNotifications

struct NotificationHelper {
    static let notificationCenter = UNUserNotificationCenter.current()
}

// MARK: - Models

/// Represents a single item in a list (header + body + optional image)
struct OTDItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var header: String?
    var body: String?
    var imageReference: String?
    
    var isEmpty: Bool {
        header == nil && body == nil && imageReference == nil
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

/// Represents a list of "Of The Day" items, with user settings
struct OTDList: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var items: [OTDItem]
    var itemOrder: [Int]
    var currentItem: Int = 0
    
    // User settings
    var isVisible: Bool = true
    var isShuffled: Bool = false
    var notificationsOn: Bool = false
    var notificationTime: Date?
    // ?? what if list goes inactive then active, will notifs turn back on?
    
    // Images
    var imageReferences: [String] = []
    
    
    /// Updates the current item if a day has passed since last update.
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
    
    // MARK: - Notifications for this specific list
    
    /// Schedules a daily notification for this list’s current item, if notificationsOn == true and list is visible.
    /// We pass in the notification center from outside for clarity.
    mutating func enableNotifications() {
        guard notificationsOn, isVisible, !items.isEmpty, let notificationTime = notificationTime else {
                return
            }
            
            // Remove any existing notifications for this list
            disableNotifications()
            
            let content = UNMutableNotificationContent()
        
        print("enabling notifs for item", currentItem)
            
            let currentTitle = title
            let currentHeader = items[currentItem].header
            let currentBody = items[currentItem].body
            
            // Configure notification content
            switch (currentHeader, currentBody) {
            case let (h?, b?):
                content.title = h
                content.body  = b
            case (nil, let b?):
                content.title = currentTitle
                content.body  = b
            case (let h?, nil):
                content.title = currentTitle
                content.body  = h
            default:
                content.title = currentTitle
                content.body  = "No content available."
            }
        
            // saving the current item/list so pressing the notification can open back to it later
            content.userInfo = [
                "listIDstring": id.uuidString,
                "itemIDstring": items[currentItem].id.uuidString
            ]
            
            var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
            dateComponents.timeZone = TimeZone.current
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
            
            // Use the static notificationCenter
            NotificationHelper.notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled for list \(currentTitle)")
                }
            }
        }
        
        // ?? used inside function, this is stupid code, please find a better way
        mutating func disableNotifications() {
            NotificationHelper.notificationCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
            print("Notifications disabled for list \(title)")
        }
    
    /// Removes pending notifications for this list
    mutating func disableNotifications(using notificationCenter: UNUserNotificationCenter) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        print("Notifications disabled for list \(title)")
    }
}


struct OTDAllLists: Codable {
    var lists: [OTDList]
    var currentList: Int = 0
    var maxImagesPerlist: Int = 10
    
    mutating func updateAllLists() {
        for index in 0..<lists.count {
            lists[index].updateCurrentItem()
        }
    }
}
