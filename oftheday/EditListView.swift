//
//  EditListView.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//

import SwiftUI

// MARK: - Edit List View

/// A modal view (sheet) that shows all items in the selected list.
/// You can add new items, delete items, and tap to edit any item.
struct EditListView: View {
    @EnvironmentObject var viewModel: OTDViewModel
    
    /// Whether this sheet is presented
    @Binding var isPresented: Bool
    
    /// The index of the list we are editing
    var listIndex: Int
    
    // State to manage presenting the edit for a specific item
    @State private var showEditItem = false
    @State private var editingIndex: Int? = nil
    
    var body: some View {
        NavigationView {
            if listIndex < viewModel.lists.count {
                let listTitle = viewModel.lists[listIndex].title
                
                List {
                    ForEach(Array(viewModel.lists[listIndex].items.enumerated()), id: \.1.id) { index, item in
                        // Each row: tap to edit
                        Button(action: {
                            editingIndex = index
                            showEditItem = true
                        }) {
                            VStack(alignment: .leading) {
                                Text(item.header).bold()
                                if !item.body.isEmpty {
                                    Text(item.body)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        viewModel.lists[listIndex].items.remove(atOffsets: offsets)
                    }
                }
                .navigationTitle("Edit \(listTitle)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button(action: {
                        // Create a blank item and edit it
                        let newItem = OTDItem(header: "New Item", body: "")
                        viewModel.lists[listIndex].items.append(newItem)
                        editingIndex = viewModel.lists[listIndex].items.count - 1
                        showEditItem = true
                    }) {
                        Image(systemName: "plus")
                    },
                    trailing: Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                    }
                )
                .sheet(isPresented: $showEditItem) {
                    if let index = editingIndex {
                        EditItemView(
                            item: Binding(
                                get: { viewModel.lists[listIndex].items[index] },
                                set: { viewModel.lists[listIndex].items[index] = $0 }
                            )
                        )
                    }
                }
            } else {
                Text("Invalid list index.")
                    .padding()
                    .navigationBarItems(trailing: Button("Close") {
                        isPresented = false
                    })
            }
        }
    }
}
