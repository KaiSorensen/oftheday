import SwiftUI

struct EditListView: View {
    /// The entire “Of The Day” data model, passed by binding so we can edit in-place.
    @Binding var allLists: OTDAllLists
    
    /// Whether this edit view is visible/presented.
    @Binding var isPresented: Bool
    
    /// Controls whether we’re currently showing an item editor (sheet).
    @State private var showEditItem = false
    
    /// Indicates if the current sheet is for adding a new item.
    @State private var isAddingNewItem = false
    
    /// Temporary item for adding a new entry.
    @State private var newItem = OTDItem(header: nil, body: nil, imageName: nil)
    
    /// The index of the item we’re currently editing (if any).
    @State private var editingIndex: Int? = nil
    
    /// Temporary item for editing an existing entry.
    @State private var editingItem = OTDItem(header: nil, body: nil, imageName: nil)
    
    /// Tracks if the user confirmed the action in the sheet.
    @State private var didConfirm = false

    // Convenience: easy access to the current list (if it exists).
    private var currentListBinding: Binding<OTDList>? {
        guard allLists.lists.indices.contains(allLists.currentList) else {
            return nil
        }
        return Binding<OTDList>(
            get: {
                allLists.lists[allLists.currentList]
            },
            set: {
                allLists.lists[allLists.currentList] = $0
            }
        )
    }

    var body: some View {
        NavigationView {
            if let currentList = currentListBinding {
                List {
                    // Enumerate the items in the current list
                    ForEach(Array(currentList.wrappedValue.items.enumerated()), id: \.element.id) { (index, item) in
                        Button {
                            // Begin editing an existing item
                            editingIndex = index
                            editingItem = currentList.wrappedValue.items[index]
                            didConfirm = false
                            showEditItem = true
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.header?.isEmpty == false ? item.header! : "Untitled")
                                    .bold()
                                    .foregroundColor(
                                        (item.header?.isEmpty ?? true) ? .secondary : .primary
                                    )
                                if let body = item.body, !body.isEmpty {
                                    Text(body)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                } else {
                                    Text("No description")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        // Remove the items at these offsets
                        currentList.wrappedValue.items.remove(atOffsets: offsets)
                    }
                }
                .navigationTitle("Edit \(currentList.wrappedValue.title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            // Initiate adding a new item
                            isAddingNewItem = true
                            newItem = OTDItem(header: nil, body: nil, imageName: nil)
                            didConfirm = false
                            showEditItem = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Close the entire EditListView
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                // Show the EditItemView as a sheet
                .sheet(isPresented: $showEditItem, onDismiss: {
                    if isAddingNewItem {
                        // Handle adding a new item
                        if didConfirm,
                           !(newItem.header == nil && newItem.body == nil && newItem.imageName == nil) {
                            // Only append if the user confirmed and at least one field is not nil
                            currentList.wrappedValue.items.append(newItem)
                        }
                        // Reset add-related states
                        isAddingNewItem = false
                        newItem = OTDItem(header: nil, body: nil, imageName: nil)
                        didConfirm = false
                    } else if let index = editingIndex {
                        // Handle editing an existing item
                        if didConfirm {
                            if currentList.wrappedValue.items.indices.contains(index) {
                                currentList.wrappedValue.items[index] = editingItem
                                let editedItem = currentList.wrappedValue.items[index]
                                if editedItem.header == nil && editedItem.body == nil && editedItem.imageName == nil {
                                    // Remove the item since it's empty
                                    currentList.wrappedValue.items.remove(at: index)
                                }
                            }
                        }
                        // Reset edit-related states
                        editingIndex = nil
                        editingItem = OTDItem(header: nil, body: nil, imageName: nil)
                        didConfirm = false
                    }
                }) {
                    if isAddingNewItem {
                        // Present EditItemView for adding a new item
                        EditItemView(item: $newItem, didConfirm: $didConfirm)
                    } else if let index = editingIndex,
                              currentList.wrappedValue.items.indices.contains(index) {
                        // Present EditItemView for editing an existing item
                        EditItemView(item: $editingItem, didConfirm: $didConfirm)
                    } else {
                        // Fallback view if something goes wrong
                        Text("Unable to edit item.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            } else {
                // Handle case where the selected list does not exist
                Text("The selected list does not exist.")
                    .foregroundColor(.secondary)
                    .padding()
                    .navigationTitle("Edit List")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isPresented = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
            }
        }
    }
}
