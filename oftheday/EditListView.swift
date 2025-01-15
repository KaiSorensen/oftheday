import SwiftUI

struct EditListView: View {
    @ObservedObject var viewModel: OTDViewModel
    @Binding var isPresented: Bool
    
    // Controls whether we’re currently showing the sheet for creating/editing an item
    @State private var showEditItem = false
    
    // Indicates if the current sheet is for adding a new item.
    @State private var isAddingNewItem = false
    
    // Temporary item for adding a new entry.
    @State private var newItem = OTDItem(header: nil, body: nil, imageName: nil)
    
    // The index (in itemOrder) we’re currently editing (if any).
    @State private var editingOrderIndex: Int? = nil
    
    // Temporary item for editing an existing entry.
    @State private var editingItem = OTDItem(header: nil, body: nil, imageName: nil)
    
    // Tracks if the user confirmed in the sheet.
    @State private var didConfirm = false
    
    var body: some View {
        NavigationView {
            if viewModel.allLists.lists.indices.contains(viewModel.allLists.currentList) {
                let currentList = viewModel.allLists.lists[viewModel.allLists.currentList]
                
                List {
                    // We show items in the order determined by currentList.itemOrder:
                    ForEach(Array(currentList.itemOrder.enumerated()), id: \.element) { (orderIndex, itemIndex) in
                        // Safety check:
                        if currentList.items.indices.contains(itemIndex) {
                            let item = currentList.items[itemIndex]
                            Button {
                                // Begin editing
                                editingOrderIndex = orderIndex
                                editingItem = item
                                didConfirm = false
                                showEditItem = true
                                isAddingNewItem = false
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(item.header?.isEmpty == false
                                         ? item.header!
                                         : "Untitled")
                                        .bold()
                                        .foregroundColor(
                                            (item.header?.isEmpty ?? true)
                                            ? .secondary
                                            : .primary
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
                    }
                    .onDelete { offsets in
                        // offsets is for the *displayed* rows, which correspond
                        // to currentList.itemOrder.enumerated()
                        for offset in offsets {
                            // Call removeItem(orderIndex:) on each offset
                            viewModel.removeItem(orderIndex: offset)
                        }
                    }
                    .onMove { source, destination in
                        // Reorder the *itemOrder* array
                        viewModel.moveItem(source: source, destination: destination)
                       
                    }
                }
                .navigationTitle("Edit \(currentList.title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // The plus sign
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button {
                                // Initiate adding a new item
                                isAddingNewItem = true
                                newItem = OTDItem(header: nil, body: nil, imageName: nil)
                                didConfirm = false
                                showEditItem = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            
                            // Shuffle toggle button to the right of the plus
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
                // Show the EditItemView as a sheet
                .sheet(isPresented: $showEditItem, onDismiss: {
                    if isAddingNewItem {
                        // If user confirmed, and item has anything in it, call addItem
                        if didConfirm,
                           !(newItem.header == nil
                             && newItem.body == nil
                             && newItem.imageName == nil) {
                            viewModel.addItem(item: newItem)
                        }
                        // Reset add-related states
                        isAddingNewItem = false
                        newItem = OTDItem(header: nil, body: nil, imageName: nil)
                        didConfirm = false
                        
                    } else if let oIndex = editingOrderIndex {
                        if didConfirm {
                            // Overwrite the item, but if it’s "empty", remove it
                            let currListIndex = viewModel.allLists.currentList
                            // Safety check
                            if viewModel.allLists.lists[currListIndex].itemOrder.indices.contains(oIndex) {
                                let itemIndex = viewModel.allLists.lists[currListIndex].itemOrder[oIndex]
                                
                                // If still in range, update or remove
                                if viewModel.allLists.lists[currListIndex].items.indices.contains(itemIndex) {
                                    viewModel.allLists.lists[currListIndex].items[itemIndex] = editingItem
                                    let edited = viewModel.allLists.lists[currListIndex].items[itemIndex]
                                    if  edited.header == nil &&
                                        edited.body == nil &&
                                        edited.imageName == nil {
                                        // remove it
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
                }) {
                    if isAddingNewItem {
                        // Present EditItemView for adding a new item
                        EditItemView(item: $newItem, didConfirm: $didConfirm)
                    } else if let oIndex = editingOrderIndex,
                              currentList.itemOrder.indices.contains(oIndex) {
                        // Present EditItemView for editing an existing item
                        EditItemView(item: $editingItem, didConfirm: $didConfirm)
                    } else {
                        // Fallback
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
