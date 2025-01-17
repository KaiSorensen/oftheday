//
//  HomeView.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case listNotification
    case editList
    
    var id: Int {
        hashValue
    }
}

// MARK: - Home View

struct HomeView: View {
    @EnvironmentObject var viewModel: OTDViewModel
    
    @Binding var showWidgetSettings: Bool
    @Binding var showMainMenu: Bool
    
    @State private var activeSheet: ActiveSheet?
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                // Top bar with widget settings & main menu
                HStack {
                    Button(action: {
                        showWidgetSettings.toggle()
                    }) {
                        Image(systemName: "square.grid.2x2")
                            .font(.title3)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showMainMenu.toggle()
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title3)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Chips row
                ChipsRowView(selectedIndex: $viewModel.allLists.currentList, lists: viewModel.allLists.lists)
                    .padding(.vertical, 8)
                
                // list buttons
                HStack(spacing: 20) {
                    // shuffle button
                    Button(action: {
                        viewModel.toggleShuffle()
                    }) {
                        Image(systemName: viewModel.currentList.isShuffled ? "shuffle.circle.fill" : "shuffle.circle")
                            .font(.title2)
                    }
                    
                    // notification button
                    Button(action: {
                        activeSheet = .listNotification
                    }) {
                        Image(systemName: viewModel.currentList.notificationsOn ? "bell.circle.fill" : "bell.circle")
                    }
                    
                    // Edit button
                    Button(action: {
                        activeSheet = .editList
                    }) {
                        Image(systemName: "hammer.circle")
                            .font(.title2)
                    }
                }
                .padding(.bottom, 8)
                
                // Main card area (with gestures)
                GeometryReader { geo in
                    // We use a ZStack or similar here so we can apply gesture
                    ZStack {
                        CardView(item: viewModel.currentItem)
                            .frame(
                                width: geo.size.width * 0.9,
                                height: geo.size.height * 0.8
                            )
                            .animation(.easeInOut, value: viewModel.currentItem.id)
                            // The card animates when the item changes
                            .gesture(
                                DragGesture(minimumDistance: 30)
                                    .onEnded { value in
                                        let horizontalDistance = value.translation.width
                                        let verticalDistance = value.translation.height
                                        
                                        // Determine if the swipe was mostly horizontal or vertical
                                        if abs(horizontalDistance) > abs(verticalDistance) {
                                            // Horizontal swipe
                                            if horizontalDistance < 0 {
                                                // Swipe left
                                                viewModel.nextList()
                                            } else {
                                                // Swipe right
                                                viewModel.prevList()
                                            }
                                        } else {
                                            // Vertical swipe
                                            if verticalDistance < 0 {
                                                // Swipe up
                                                viewModel.nextItem()
                                            } else {
                                                // Swipe down
                                                viewModel.prevItem()
                                            }
                                        }
                                    }
                            )
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
        }
        // Present the edit list sheet
        .sheet(item: $activeSheet) {
            sheet in switch sheet {
                
                case .editList:
                    EditListView(viewModel: viewModel, activeSheet: $activeSheet)
                    
                case .listNotification:
                    ListNotificationView(viewModel: viewModel, activeSheet: $activeSheet)
            }
        }
        .preferredColorScheme(.none) // Let the system handle dark/light
    }
}
