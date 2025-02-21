////
////  ListImagesView.swift
////  oftheday
////
////  Created by Kai Sorensen on 1/30/25.
////
//
//import SwiftUI
//
//struct ListImagesView: View {
//    /// A binding to your main ViewModel
//    @ObservedObject var viewModel: OTDViewModel
//    
//    /// Maximum number of images allowed to be selected
//    @State var maxSelectedImages: Int
//    
//    /// Control whether the image picker is presented
//    @State var isOverlayPresented = false
//    
//    /// Provide your own dismissal mechanism if needed
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        let listIndex = viewModel.allLists.currentList
//        let list = viewModel.allLists.lists[listIndex]
//        
//        return AnyView(
//            VStack(spacing: 0) {
//                // Top bar: checkmark button on the right
//                HStack {
//                    Spacer()
//                    Button {
//                        // Dismiss the page
//                        presentationMode.wrappedValue.dismiss()
//                    } label: {
//                        Image(systemName: "checkmark")
//                            .font(.headline)
//                            .padding()
//                            .foregroundColor(.blue)
//                    }
//                }
//                
//                // "Add Photos" big blue button
//                Button {
//                    // Show your image selector overlay
//                    isOverlayPresented = true
//                } label: {
//                    Text("Add Photos")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .background(Color.blue)
//                        .cornerRadius(8)
//                        .padding(.horizontal)
//                }
//                .padding(.bottom, 8)
//                
//                // Scrollable grid of images (2 columns)
//                ScrollView {
//                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
//                        ForEach(list.imageReferences, id: \.self) { reference in
//                            ZStack(alignment: .topLeading) {
//                                // Attempt to load the image
//                                if let uiImage = ImageTable.imageTable.getImage(byID: reference) {
//                                    Image(uiImage: uiImage)
//                                        .resizable()
//                                        .scaledToFit()
//                                        .cornerRadius(8)
//                                        .padding(4)
//                                } else {
//                                    // Fallback if image can’t be loaded
//                                    Rectangle()
//                                        .fill(Color.gray.opacity(0.2))
//                                        .cornerRadius(8)
//                                        .padding(4)
//                                }
//                                
//                                // X circle button (top-left corner)
//                                Button {
//                                    // Remove from the list’s references
//                                    viewModel.removeListImage(imageRef: reference)
//                                    ImageTable.imageTable.decrementReference(for: reference)
//                                } label: {
//                                    Image(systemName: "xmark.circle.fill")
//                                        .font(.title2)
//                                        .foregroundColor(.red)
//                                        .padding(4)
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//                .frame(maxWidth: .infinity)
//                
//                Spacer()
//            }
//            .fullScreenCover(isPresented: $isOverlayPresented) {
//                // Your existing overlay
//                ImageSelectorOverlay(
//                    itemIndex: nil,              // nil because we’re dealing with the list
//                    isPresented: $isOverlayPresented,
//                    maxSelectedImages: $maxSelectedImages,
//                    viewModel: viewModel           // pass in your viewModel or whatever param it expects
//                )
//            }
//        )
//    }
//}
