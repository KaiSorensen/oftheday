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

}
