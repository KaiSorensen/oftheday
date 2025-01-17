//
//  ListNotification.swift
//  oftheday
//
//  Created by user268370 on 1/17/25.
//

import SwiftUI

struct ListNotificationView {
    @ObservedObject var viewModel: OTDViewModel
    @Binding var activeSheet: ActiveSheet?
    
    var body: some View {
        
        VStack {
            DatePicker(
                "Time of Day",
                selection: $notificationTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(WheelDatePickerStyle())
            .padding()
            
            Button("Schedule Notification") {
                requestNotificationPermission()
                scheduleDailyNotification(at: notificationTime)
            }
            .padding()
        }
        
        
    }

}
