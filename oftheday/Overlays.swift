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

struct ListManagementOverlay: View {
    @ObservedObject var viewModel: OTDViewModel
    @Binding var showOverlay: Bool
    
    // State variables for handling alerts and sheets
    @State private var showDeleteConfirmation = false
    @State private var listToDelete: OTDList?
    
    @State private var showAddListSheet = false
    @State private var newListTitle: String = ""
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showOverlay = false
                    }
                }
            
            // Overlay content
            VStack {
                Text("Manage Lists")
                    .font(.headline)
                    .padding()
                
                List {
                    ForEach(viewModel.allLists.lists.indices, id: \.self) { index in
                        let list = viewModel.allLists.lists[index]
                        HStack {
                            Text(list.title)
                                .font(.body)
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { list.isVisible },
                                set: { _ in
                                    withAnimation {
                                        viewModel.toggleVisibility(for: list)
                                    }
                                }
                            ))
                            .labelsHidden()
                        }
                        .contentShape(Rectangle()) // Makes entire row tappable
                        .contextMenu {
                            Button(role: .destructive) {
                                listToDelete = list
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if let first = indexSet.first {
                            listToDelete = viewModel.allLists.lists[first]
                            showDeleteConfirmation = true
                        }
                    }
                    .onMove(perform: viewModel.moveList)
                }
                .listStyle(PlainListStyle())
                
                HStack {
                    Button(action: {
                        showAddListSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add List")
                        }
                    }
                    Spacer()
                    EditButton()
                }
                .padding([.horizontal, .bottom])
            }
            .frame(maxWidth: 350, maxHeight: 500)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding()
        }
        // Delete Confirmation Alert
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete List"),
                message: Text("Are you sure you want to delete \"\(listToDelete?.title ?? "this list")\"?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let list = listToDelete, let index = viewModel.allLists.lists.firstIndex(where: { $0.id == list.id }) {
                        viewModel.removeList(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        // Add List Sheet
        .sheet(isPresented: $showAddListSheet) {
            NavigationView {
                VStack {
                    TextField("List Title", text: $newListTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Spacer()
                }
                .navigationBarTitle("New List", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showAddListSheet = false
                        newListTitle = ""
                    },
                    trailing: Button("Add") {
                        let trimmedTitle = newListTitle.trimmingCharacters(in: .whitespaces)
                        if !trimmedTitle.isEmpty {
                            viewModel.addList(title: trimmedTitle)
                            showAddListSheet = false
                            newListTitle = ""
                        }
                    }
                    .disabled(newListTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                )
            }
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
