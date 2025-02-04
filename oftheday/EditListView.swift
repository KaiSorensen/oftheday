import SwiftUI

struct EditListView: View {
    @ObservedObject var viewModel: OTDViewModel
    @Binding var isPresented: Bool
    
    @State private var showAddItem = false
    @State private var showEditItem = false
    @State private var showListImages = false
    
    @State private var editingOrderIndex: Int? = nil
    @State private var newItem = OTDItem(header: nil, body: nil, imageReference: nil)
    @State private var editingItem = OTDItem(header: nil, body: nil, imageReference: nil)
    
    @State private var didConfirm = false
    
    var body: some View {
        NavigationView {
            if viewModel.allLists.lists.indices.contains(viewModel.allLists.currentList) {
                let currentList = viewModel.allLists.lists[viewModel.allLists.currentList]
                
                List {
                    ForEach(Array(currentList.itemOrder.enumerated()), id: \.element) { (orderIndex, itemIndex) in
                        if currentList.items.indices.contains(itemIndex) {
                            let item = currentList.items[itemIndex]
                            Button {
                                // Begin editing this existing item
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
                        for offset in offsets {
                            viewModel.removeItem(orderIndex: offset)
                        }
                    }
                    .onMove { source, destination in
                        viewModel.moveItem(source: source, destination: destination)
                    }
                }
                .navigationTitle("\(currentList.title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button {
                                newItem = OTDItem(header: nil, body: nil, imageReference: nil)
                                didConfirm = false
                                showAddItem = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            Button {
                                viewModel.toggleShuffle()
                            } label: {
                                Image(systemName: viewModel.currentList.isShuffled
                                      ? "shuffle.circle.fill"
                                      : "shuffle.circle")
                                    .font(.title2)
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                showListImages = true
                            } label: {
                                Image(systemName: "photo")
                            }
                            Button {
                                isPresented = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        EditButton()
                    }
                }
                .sheet(isPresented: $showListImages) {
                    ListImagesView(
                        viewModel: viewModel,
                        maxSelectedImages: (
                            viewModel.allLists.maxImagesPerlist
                            - viewModel.currentList.imageReferences.count
                        )
                    )
                }
                // No onDismiss here for the add-item sheet:
                .sheet(isPresented: $showAddItem, onDismiss: handleAddItemDismiss) {
                    EditItemView(item: $newItem, didConfirm: $didConfirm)
                }
                // For editing existing items, do NOT use onDismiss; we'll observe showEditItem changes.
                .sheet(isPresented: $showEditItem) {
                    EditItemView(item: $editingItem, didConfirm: $didConfirm)
                }
                // This block detects when the user truly finishes closing the edit sheet.
                .onChange(of: showEditItem) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        handleEditItemDismiss()
                    }
                }
                
            } else {
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
    
    private func handleAddItemDismiss() {
        if didConfirm, !(newItem.header == nil && newItem.body == nil && newItem.imageReference == nil) {
            viewModel.addItem(item: newItem)
        }
        newItem = OTDItem(header: nil, body: nil, imageReference: nil)
        didConfirm = false
    }
    
    private func handleEditItemDismiss() {
        // If the user tapped the "Confirm" checkmark in EditItemView:
        if let oIndex = editingOrderIndex, didConfirm {
            let listIndex = viewModel.allLists.currentList
            if viewModel.allLists.lists[listIndex].itemOrder.indices.contains(oIndex) {
                let itemIndex = viewModel.allLists.lists[listIndex].itemOrder[oIndex]
                if viewModel.allLists.lists[listIndex].items.indices.contains(itemIndex) {
                    // Update the item
                    viewModel.allLists.lists[listIndex].items[itemIndex] = editingItem
                    
                    // If it became entirely empty, remove it
                    if editingItem.header == nil,
                       editingItem.body == nil,
                       editingItem.imageReference == nil {
                        viewModel.removeItem(orderIndex: oIndex)
                    }
                }
            }
        }
        
        // Finally, reset all our editing state so we start fresh next time.
        editingOrderIndex = nil
        editingItem = OTDItem(header: nil, body: nil, imageReference: nil)
        didConfirm = false
    }
}
