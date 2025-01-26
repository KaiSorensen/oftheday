import SwiftUI

struct EditListView: View {
    @ObservedObject var viewModel: OTDViewModel
    @Binding var isPresented: Bool
    
    // Controls presentation of add and edit sheets separately
    @State private var showAddItem = false
    @State private var showEditItem = false
    
    // Indicates if we're currently editing an existing item
    @State private var editingOrderIndex: Int? = nil
    
    // Temporary items for adding and editing
    @State private var newItem = OTDItem(header: nil, body: nil, imageName: nil)
    @State private var editingItem = OTDItem(header: nil, body: nil, imageName: nil)
    
    // Tracks if the user confirmed in the sheet
    @State private var didConfirm = false
    
    var body: some View {
        NavigationView {
            if viewModel.allLists.lists.indices.contains(viewModel.allLists.currentList) {
                let currentList = viewModel.allLists.lists[viewModel.allLists.currentList]
                
                List {
                    // Display items in the order determined by currentList.itemOrder
                    ForEach(Array(currentList.itemOrder.enumerated()), id: \.element) { (orderIndex, itemIndex) in
                        // Safety check
                        if currentList.items.indices.contains(itemIndex) {
                            let item = currentList.items[itemIndex]
                            Button {
                                // Begin editing
                                editingOrderIndex = orderIndex
                                editingItem = item
                                didConfirm = false
                                showEditItem = true
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.header?.isEmpty == false ? item.header! : "Untitled")
                                        .bold()
                                        .foregroundColor((item.header?.isEmpty ?? true) ? .secondary : .primary)
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
                    }
                    .onDelete { offsets in
                        // Remove items based on displayed offsets
                        for offset in offsets {
                            viewModel.removeItem(orderIndex: offset)
                        }
                    }
                    .onMove { source, destination in
                        // Reorder the itemOrder array
                        viewModel.moveItem(source: source, destination: destination)
                    }
                }
                .navigationTitle("\(currentList.title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Add and Shuffle buttons
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button {
                                // Initiate adding a new item
                                newItem = OTDItem(header: nil, body: nil, imageName: nil)
                                didConfirm = false
                                showAddItem = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            
                            Button {
                                viewModel.toggleShuffle()
                            } label: {
                                Image(systemName: viewModel.currentList.isShuffled ? "shuffle.circle.fill" : "shuffle.circle")
                                    .font(.title2)
                            }
                        }
                    }
                    
                    // “Done” or “Close” button
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    // EditButton for SwiftUI’s .onMove
                    ToolbarItem(placement: .bottomBar) {
                        EditButton()
                    }
                }
                // Sheet for Adding a New Item
                .sheet(isPresented: $showAddItem, onDismiss: handleAddItemDismiss) {
                    EditItemView(item: $newItem, didConfirm: $didConfirm)
                }
                // Sheet for Editing an Existing Item
                .sheet(isPresented: $showEditItem, onDismiss: handleEditItemDismiss) {
                    EditItemView(item: $editingItem, didConfirm: $didConfirm)
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
    
    // Handle dismissal of Add Item Sheet
    private func handleAddItemDismiss() {
        if didConfirm,
           !(newItem.header == nil && newItem.body == nil && newItem.imageName == nil) {
            viewModel.addItem(item: newItem)
        }
        // Reset add-related states
        newItem = OTDItem(header: nil, body: nil, imageName: nil)
        didConfirm = false
    }
    
    // Handle dismissal of Edit Item Sheet
    private func handleEditItemDismiss() {
        if let oIndex = editingOrderIndex, didConfirm {
            let currListIndex = viewModel.allLists.currentList
            // Safety check
            if viewModel.allLists.lists[currListIndex].itemOrder.indices.contains(oIndex) {
                let itemIndex = viewModel.allLists.lists[currListIndex].itemOrder[oIndex]
                
                // If still in range, update or remove
                if viewModel.allLists.lists[currListIndex].items.indices.contains(itemIndex) {
                    viewModel.allLists.lists[currListIndex].items[itemIndex] = editingItem
                    let edited = viewModel.allLists.lists[currListIndex].items[itemIndex]
                    if edited.header == nil && edited.body == nil && edited.imageName == nil {
                        // Remove the item if it's empty
                        viewModel.removeItem(orderIndex: oIndex)
                    }
                }
            }
        }
        // Reset edit-related states
        editingOrderIndex = nil
        editingItem = OTDItem(header: nil, body: nil, imageName: nil)
        didConfirm = false
    }
}
