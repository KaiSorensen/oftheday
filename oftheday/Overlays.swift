//
//  SettingsOverlay.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//

import SwiftUI


// MARK: - Overlays

struct SettingsOverlay: View {
    @Binding var showOverlay: Bool
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss overlay if tapped outside
                    showOverlay = false
                }
            
            // Overlay container
            VStack {
                Text("Widget Settings")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Placeholder for future widget settings
                Text("Configure widget options here…")
                    .padding()
                
                Spacer()
                
                Button("Close") {
                    showOverlay = false
                }
                .padding()
            }
            .frame(maxWidth: 300, maxHeight: 300)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

struct MainMenuOverlay: View {
    @Binding var showOverlay: Bool
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss overlay if tapped outside
                    showOverlay = false
                }
            
            // Overlay container
            VStack {
                Text("Main Menu")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Placeholder for future app/account settings
                Text("App and account settings go here…")
                    .padding()
                
                Spacer()
                
                Button("Close") {
                    showOverlay = false
                }
                .padding()
            }
            .frame(maxWidth: 300, maxHeight: 300)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

struct TimePickerOverlay: View {
    @ObservedObject var viewModel: OTDViewModel
    @Binding var showOverlay: Bool
    @Binding var notificationsEnabled: Bool
    
    @State private var selectedTime = Date() // Bind this to capture the selected time
    
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss overlay if tapped outside
                    showOverlay = false
                }
            
            // Overlay container
            VStack {
                if !notificationsEnabled {
                    Text("Notifications for this app are disabled.")
                        .font(.system(size: 40))
                } else {
                    
                    Text("Set Daily \(viewModel.currentList.title)")
                        .font(.headline)
                    
                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute // Restrict to hour and minute selection
                    )
                    .datePickerStyle(.wheel) // Style for better user experience
                    
                    Button("Notify at \(formattedTime(for: selectedTime))") {
                        viewModel.allLists.lists[viewModel.allLists.currentList].notificationsOn = true
                        showOverlay = false // Dismiss the overlay
                        viewModel.allLists.lists[viewModel.allLists.currentList].notificationTime = selectedTime
                        // here we set the recurring notification. It relies on the content, so maybe it should be done in the models file where the content resides
                        viewModel.enablePushNotificationsCurrentList()
                    }
                }
            }
            .frame(maxWidth: 300, minHeight: 300)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
        
        
    }
    
    // Function to format the selected time for display
    private func formattedTime(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short // Automatically adjusts for 24-hour or 12-hour based on user settings
        return formatter.string(from: date)
    }
    
}
