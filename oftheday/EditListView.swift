import SwiftUI

struct EditListView: View {
    @ObservedObject var listModel: OTDListModel
    @Binding var isPresented: Bool
    @EnvironmentObject var userModel: OTDUserModel

    @State private var showAddItem = false
    @State private var showEditItem = false
    @State private var showListImages = false
    @State private var showParser = false

    @State private var editingOrderIndex: Int? = nil
    @State private var newItem = OTDItem(header: nil, body: nil)
    @State private var editingItem = OTDItem(header: nil, body: nil)
    
    @State private var didConfirm = false

    var body: some View {
        NavigationView {
            if let listItems = listModel.listItems {
                List {
                    ForEach(Array(listItems.itemOrder.enumerated()), id: \.element) { (orderIndex, itemIndex) in
                        if listItems.items.indices.contains(itemIndex) {
                            let item = listItems.items[itemIndex]
                            Button {
                                // Begin editing this existing item.
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
                            listModel.removeItem(orderIndex: offset)
                        }
                    }
                    .onMove { source, destination in
                        listModel.moveItem(source: source, destination: destination)
                    }
                }
                .navigationTitle("\(listModel.metadata.title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    // Left–side toolbar items.
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            Button {
                                newItem = OTDItem(header: nil, body: nil)
                                didConfirm = false
                                showAddItem = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            Button {
                                // Toggle shuffle: for example, shuffle the itemOrder.
                                if var items = listModel.listItems {
                                    items.shuffleItems()
                                    listModel.listItems = items
                                }
                            } label: {
                                Image(systemName: "shuffle.circle")
                                    .font(.title2)
                            }
                        }
                    }
                    
                    // Right–side toolbar items.
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            Button {
                                listModel.metadata.today.toggle()
                                    // Propagate the change to the shared user model.
                                userModel.updateTodayFlag(for: listModel.metadata.id, to: listModel.metadata.today)
                            } label: {
                                Image(systemName: listModel.metadata.today ? "checkmark.circle.fill" : "checkmark.circle")
                            }
                            Button {
                                showParser = true
                            } label: {
                                Image(systemName: "star.fill")
                            }
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
                    
                    // Bottom bar with the EditButton.
                    ToolbarItem(placement: .bottomBar) {
                        EditButton()
                    }
                })
                .sheet(isPresented: $showParser) {
                    // Propagate the updated view model to ParserView.
                    Text("parser")

//                    ParserView(isPresented: $showParser, listModel: listModel)
                }
                .sheet(isPresented: $showListImages) {
                    // Assuming ListImagesView now takes an OTDListModel.
                    Text("edit list image")

//                    ListImagesView(
//                        listModel: listModel,
//                        maxSelectedImages: (5 - (listModel.metadata.listImage == nil ? 0 : 1))
//                    )
                }
//                // Sheet for adding a new item.
//                .sheet(isPresented: $showAddItem, onDismiss: handleAddItemDismiss) {
//                    Text("edititemview")
////                    EditItemView(item: $newItem, didConfirm: $didConfirm)
//                }
//                // Sheet for editing an existing item.
//                .sheet(isPresented: $showEditItem) {
//                    Text("edititemview")
////                    EditItemView(item: $editingItem, didConfirm: $didConfirm)
//                }
//                // Detect when the edit sheet is dismissed to update the list.
//                .onChange(of: showEditItem) { oldValue, newValue in
//                    if oldValue == true && newValue == false {
////                        handleEditItemDismiss()
//                    }
//                }
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

//    private func handleAddItemDismiss() {
//        if didConfirm, !(newItem.header == nil && newItem.body == nil) {
//            listModel.addItem(item: newItem)
//        }
//        newItem = OTDItem(header: nil, body: nil)
//        didConfirm = false
//    }
    
//    private func handleEditItemDismiss() {
//        if let oIndex = editingOrderIndex, didConfirm, var items = listModel.listItems {
//            if items.itemOrder.indices.contains(oIndex) {
//                let itemIndex = items.itemOrder[oIndex]
//                if items.items.indices.contains(itemIndex) {
//                    // Update the edited item.
//                    items.items[itemIndex] = editingItem
//                    
//                    // If the item is entirely empty, remove it.
//                    if editingItem.header == nil,
//                       editingItem.body == nil${
//                        listModel.removeItem(orderIndex: oIndex)
//                    }
//                    listModel.listItems = items
//                }
//            }
//        }
//        // Reset editing state.
//        editingOrderIndex = nil
//        editingItem = OTDItem(header: nil, body: nil)
//        didConfirm = false
//    }
}
