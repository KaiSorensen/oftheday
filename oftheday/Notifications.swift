//
//  Notifications.swift
//  oftheday
//
//  Created by user268370 on 1/18/25.
//
import SwiftUI
import UserNotifications

// helper methods
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



// for when push-notifications are pressed
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        // Make this object the notification center delegate so we can capture user taps
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    /// Called when the user taps on a notification and the app opens (or when the app is in the foreground).
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Extract the data we embedded in userInfo
        if let listIDString = userInfo["listIDstring"] as? String,
           let itemIDString = userInfo["itemIDstring"] as? String,
           let listUUID = UUID(uuidString: listIDString),
           let itemUUID = UUID(uuidString: itemIDString){
            
            // Post a custom notification that we’ll pick up in SwiftUI.
            NotificationCenter.default.post(
                name: .didReceiveOTDNotification,
                object: nil,
                userInfo: ["listUUID": listUUID, "itemUUID": itemUUID]
            )
        }
        
        completionHandler()
    }
}

extension Notification.Name {
    static let didReceiveOTDNotification = Notification.Name("didReceiveOTDNotification")
}
