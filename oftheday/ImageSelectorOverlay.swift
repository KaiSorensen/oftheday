//
//  ImageSelectorOverlay.swift
//  oftheday
//
//  Created by Kai Sorensen on 1/30/25.
//

import SwiftUI
import PhotosUI

struct ImageSelectorOverlay: View {
    
    // if nil, then we're dealing with a list's image; if value, then it's an item image
    var itemIndex: Int?
    
    @Binding var isPresented: Bool
    @Binding var maxSelectedImages: Int
    
    
    @ObservedObject var viewModel: OTDViewModel
    
    // Track user-selected item results; we can transform them to your use case:
    @State private var selectedItems: [PhotosPickerItem] = []
    
    // Track imageIDs to prevent duplicates
    @State private var alreadySelectedImageIDs: Set<String> = []
    
    var body: some View {
        
        if maxSelectedImages < 1 {
            Text("Maximum images reached for list.")
            
        } else {
            
            ZStack {
                // A semi-transparent background that dims the content behind
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Tapping outside closes the overlay
                        isPresented = false
                    }
                
                VStack(spacing: 20) {
                    Text("Select up to \(maxSelectedImages) images:")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    // Using iOS 16+ PhotosPicker for demonstration
                    PhotosPicker(selection: $selectedItems, maxSelectionCount: maxSelectedImages, matching: .images) {
                        Text("Open Photo Library")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    
                    Button {
                        applySelectedImages()
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
    }
    
    /// Processes the selected images by adding them to the ImageTable
    private func applySelectedImages() {
        guard !selectedItems.isEmpty else { return }
        
        for item in selectedItems {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    print("entering applySelectedImages")
                    // Check if the image already exists
                    if let existingImageID = ImageTable.imageTable.imageExists(uiImage) {
                        print("exists")
                        // Increment reference count (if it's a duplicate, we'll decrement it later)
                        ImageTable.imageTable.incrementReference(for: existingImageID)
                        
                        

                        // the lines within the async must occur in order
                        DispatchQueue.main.async {
                            let decrement: String?
                            if let index = itemIndex {
                                decrement = viewModel.addItemImage(at: index, with: existingImageID)
                            } else {
                                decrement = viewModel.addListImage(imageRef: existingImageID)
                            }
                            // decrement  found
                            if let dec = decrement {
                                print("decrementing image")
                                ImageTable.imageTable.decrementReference(for: dec)
                            }
                        }

                
                
                        print("Image already in memory.")
                    } else {
                        // Add new image to ImageTable
                        if let newImageHash = ImageTable.imageTable.addImage(uiImage) {
                            DispatchQueue.main.async {
                                if let index = itemIndex {
                                    viewModel.addItemImage(at: index, with: newImageHash)
                                } else {
                                    viewModel.addListImage(imageRef: newImageHash)
                                }
                            }
                            print("Added new image to table.")
                        } else {
                            print("Failed to add image to ImageTable.")
                        }
                    }
                } else {
                    print("Failed to load image data.")
                }
            }
        }
    }
}
