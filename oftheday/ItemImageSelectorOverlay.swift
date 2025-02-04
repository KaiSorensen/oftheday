//
//  ItemImageSelectorOverlay.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/2/25.
//


import SwiftUI
import PhotosUI

struct ItemImageSelectorOverlay: View {
    /// Controls whether the overlay is presented.
    @Binding var isPresented: Bool

    /// Callback that passes the selected image identifier back to the caller.
    var onImageSelected: (String) -> Void
    
    /// Track user-selected image items.
    @State private var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            VStack(spacing: 20) {
                Text("Select an Image:")
                    .foregroundColor(.white)
                    .font(.headline)
                PhotosPicker(selection: $selectedItems, maxSelectionCount: 1, matching: .images) {
                    Text("Open Photo Library")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                Button {
                    processSelection()
                    isPresented = false
                } label: {
                    Text("Done")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.8))
            .cornerRadius(12)
            .padding()
        }
    }
    
    private func processSelection() {
        guard let item = selectedItems.first else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                // Check if this image already exists.
                if let existingImageID = ImageTable.imageTable.imageExists(uiImage) {
                    // Increment its reference count.
                    ImageTable.imageTable.incrementReference(for: existingImageID)
                    // Deliver the existing image ID via the callback.
                    DispatchQueue.main.async {
                        onImageSelected(existingImageID)
                    }
                } else if let newImageID = ImageTable.imageTable.addImage(uiImage) {
                    // Deliver the new image ID via the callback.
                    DispatchQueue.main.async {
                        onImageSelected(newImageID)
                    }
                } else {
                    print("Failed to add image to ImageTable.")
                }
            } else {
                print("Failed to load image data.")
            }
        }
    }
}
