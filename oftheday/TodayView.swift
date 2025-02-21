//
//  HomeView.swift
//  oftheday
//
//  Created by Kai Sorensen on 1/12/25.
//

import SwiftUI

// MARK: - Home View

struct TodayView: View {
    @ObservedObject var userModel: OTDUserModel
    
    @State private var listModel: OTDListModel? = nil
    @State private var currentItem: OTDItem? = nil
    
    //    @State private var showTimePicker = false
    //    @State private var showEditListSheet = false
    //
    //    @State private var askedForNotifications = false
    //    @State private var notificationsEnabled = false
    
    var body: some View {
        ZStack(alignment: .top) {
            
            
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // Top bar with widget settings & main menu
                let metas = userModel.getMetasToday()
                if (metas.isEmpty) {
                    Spacer()
                    
                    Text("~ pure potential ~")                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer()
                } else {
                    
                    // Chips row
                    ChipsRowView(userModel: userModel, lists: metas, listModel: $listModel, currentItem: $currentItem)
                    
                    
                        .padding(.vertical, 8)
                    
                    // Shuffle / Reshuffle / Edit row
                    //                    HStack(spacing: 20) {
                    //                        Button(action: {
                    //                            viewModel.toggleShuffle()
                    //                        }) {
                    //                            Image(systemName: viewModel.currentList.isShuffled ? "shuffle.circle.fill" : "shuffle.circle")
                    //                                .font(.title2)
                    //                        }
                    //
                    //                        Button(action: {
                    //                            if viewModel.currentList.notificationsOn {
                    //                                viewModel.allLists.lists[viewModel.allLists.currentList].notificationsOn = false
                    //
                    //                                viewModel.allLists.lists[viewModel.allLists.currentList].disableNotifications()
                    //
                    //                            } else {
                    //                                Notifications.checkNotificationSettings { enabled in
                    //                                    if enabled {
                    //                                        notificationsEnabled = true
                    //                                    } else {
                    //                                        Notifications.requestNotificationAuthorization { granted in
                    //                                            if granted {notificationsEnabled = true}
                    //                                        }
                    //
                    //                                    }
                    //                                }
                    //
                    //                                showTimePicker = true
                    //                            }
                    //                        }) {
                    //                            Image(systemName: viewModel.currentList.notificationsOn ? "bell.circle.fill" : "bell.circle")
                    //                                .font(.title2)
                    //                        }
                    //
                    //                        // Edit button
                    //                        Button(action: {
                    //                            showEditListSheet = true
                    //                        }) {
                    //                            Image(systemName: "hammer.circle")
                    //                                .font(.title2)
                    //                        }
                    //                    }
                    //                    .padding(.bottom, 8)
                    
                    //                    // Main card area (with gestures)
                    GeometryReader { geo in
                        // We use a ZStack or similar here so we can apply gesture
                        ZStack {
                            //                            // if there are images, the image it chooses for an item is based off of its index. It will cycle the images in order, but it will make sure the same image always goes to the same item unless the order changes or the images change.
                            ////                            var imageRef: String? {
                            ////                                let imgRefCount = viewModel.currentList.imageReferences.count
                            ////                                return imgRefCount > 0
                            ////                                    ? viewModel.currentList.imageReferences[viewModel.currentList.currentItem % imgRefCount]
                            ////                                    : nil
                            ////                            }
                            //
                            //
                            ItemView(item: $currentItem)
                                .frame(
                                    width: geo.size.width * 0.9,
                                    height: geo.size.height * 0.8
                                )
                            //                                .animation(.easeInOut, value: listModel?.getCurrentItem()?.id ?? UUID().currentItem.id)
                            // The card animates when the item changes
                                .gesture(
                                    metas.count > 1 ? DragGesture(minimumDistance: 30)
                                        .onEnded { value in
                                            let horizontalDistance = value.translation.width
                                            let verticalDistance = value.translation.height
                                            
                                            // Determine if the swipe was mostly horizontal or vertical
                                            if abs(horizontalDistance) > abs(verticalDistance) {
                                                // Horizontal swipe
                                                if horizontalDistance < 0 {
                                                    // Swipe left
                                                    listModel = userModel.getNextListModel()
                                                    currentItem = listModel!.getCurrentItem()
                                                } else {
                                                    // Swipe right
                                                    listModel = userModel.getPrevListModel()
                                                    currentItem = listModel!.getCurrentItem()
                                                }
                                            } else {
                                                // Vertical swipe
                                                if verticalDistance < 0 {
                                                    // Swipe up
                                                    currentItem = listModel!.nextItem()
                                                } else {
                                                    // Swipe down
                                                    currentItem = listModel!.prevItem()
                                                }
                                            }
                                        } : nil
                                )
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    
                    Spacer()
                }
                
            }
            
            //        .overlay(
            //            ZStack {
            //                if showTimePicker {
            //                    TimePickerOverlay(viewModel: viewModel, showOverlay: $showTimePicker, notificationsEnabled: $notificationsEnabled)
            //                }
            //            }
            //        )
            //        // Present the edit list sheet
            //        .sheet(isPresented: $showEditListSheet) {
            //            EditListView(viewModel: viewModel, isPresented: $showEditListSheet)
            //        }
            //        .preferredColorScheme(.none) // Let the system handle dark/light
        }
        .onAppear {
            // Ensure listModel and currentItem are set at startup
            listModel = userModel.getCurrentListModel()
            currentItem = listModel?.getCurrentItem()
            
        }
    }
}
