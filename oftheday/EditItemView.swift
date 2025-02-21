//import SwiftUI
//
//struct EditItemView: View {
//    /// The OTDItem we’re editing or creating.
//    @Binding var item: OTDItem
//
//    /// Indicates if the user confirmed the action.
//    @Binding var didConfirm: Bool
//
//    /// For dismissing this page (sheet).
//    @Environment(\.presentationMode) var presentationMode
//
//    /// Controls presentation of the image selector.
//    @State private var showImagePicker = false
//
//    var body: some View {
//        NavigationView {
//            Form {
//                // Title Section
//                Section(header: Text("Title")) {
//                    TextField("Enter title",
//                              text: Binding(
//                                get: { item.header ?? "" },
//                                set: { item.header = $0.isEmpty ? nil : $0 }
//                              ))
//                }
//
//                // Body Section
//                Section(header: Text("Body")) {
//                    TextEditor(text: Binding(
//                        get: { item.body ?? "" },
//                        set: { item.body = $0.isEmpty ? nil : $0 }
//                    ))
//                    .frame(minHeight: 120)
//                }
//
//                // Image Section
//                Section(header: Text("Image")) {
//                    if let imageRef = item.imageReference,
//                       let uiImage = ImageTable.imageTable.getImage(byID: imageRef) {
//                        // Display the current image with a tappable overlay and an “X” button to remove it.
//                        ZStack(alignment: .topLeading) {
//                            Image(uiImage: uiImage)
//                                .resizable()
//                                .scaledToFit()
//                                .onTapGesture {
//                                    // Tap to change the image.
//                                    showImagePicker = true
//                                }
//                            Button {
//                                // Remove the image from the item.
//                                item.imageReference = nil
//                            } label: {
//                                Image(systemName: "xmark.circle.fill")
//                                    .foregroundColor(.red)
//                                    .font(.title2)
//                                    .padding(4)
//                            }
//                        }
//                    } else {
//                        // If no image is set, show an “Add Image” button.
//                        Button(action: { showImagePicker = true }) {
//                            HStack {
//                                Image(systemName: "photo")
//                                Text("Add Image")
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Edit Item")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        // User pressed confirm.
//                        didConfirm = true
//                        presentationMode.wrappedValue.dismiss()
//                    } label: {
//                        Image(systemName: "checkmark")
//                    }
//                }
//            }
//            // Present the image selector as a full-screen cover.
//            .fullScreenCover(isPresented: $showImagePicker) {
//                // Note that we use a modified version of ImageSelectorOverlay for items.
//                ItemImageSelectorOverlay(isPresented: $showImagePicker) { selectedImageID in
//                    // When an image is selected, store its reference in the item.
//                    item.imageReference = selectedImageID
//                }
//            }
//        }
//    }
//}
