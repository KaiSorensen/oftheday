//
//  Notifications.swift
//  oftheday
//
//  Created by user268370 on 1/18/25.
//

import UserNotifications

struct Notifications {
    
    static func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notifications authorization: \(error.localizedDescription)")
            }
            completion(granted)
        }
    }
    
    static func checkNotificationSettings(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            completion(settings.authorizationStatus == .authorized)
        }
    }
    
    func scheduleDailyNotification(at hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        
        // Define the notification content
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "This is your daily notification."
        content.sound = .default
        
        // Configure the trigger for a specific time
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the request
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func setupDailyNotification(at hour: Int, minute: Int) {
        checkNotificationSettings { isAuthorized in
            if isAuthorized {
                scheduleDailyNotification(at: hour, minute: minute)
            } else {
                requestNotificationAuthorization { granted in
                    if granted {
                        scheduleDailyNotification(at: hour, minute: minute)
                    } else {
                        print("User denied notifications.")
                        // Optionally, show an alert to guide the user to enable notifications in settings.
                    }
                }
            }
        }
    }
    
}
setupDailyNotification(at: 8, minute: 30) // Example: 8:30 AM

