//
//  SettingsOverlay.swift
//  oftheday
//
//  Created by Kai Sorensen on 1/12/25.
//

import SwiftUI

enum SearchFilter: String, CaseIterable, Identifiable {
    case lists = "Lists"
    case items = "Items"
    
    var id: String { self.rawValue }
}

struct SearchView: View {
    @ObservedObject var userModel: OTDUserModel
    @State private var searchText: String = ""
    @State private var selectedFilter: SearchFilter = .lists
    @State private var selectedListModel: OTDListModel? = nil
    @State private var showEditListView: Bool = false

    var filteredLists: [OTDListMetadata] {
        guard let lists = userModel.currentUser?.lists else { return [] }
        return searchText.isEmpty ? lists :
            lists.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var filteredItems: [OTDItem] {
        guard let lists = userModel.currentUser?.lists else { return [] }
        let allItems: [OTDItem] = lists.flatMap { meta in
            let listModel = OTDListModel(metadata: meta)
            return listModel.listItems?.items ?? []
        }
        return searchText.isEmpty ? allItems :
            allItems.filter { item in
                let headerMatches = item.header?.localizedCaseInsensitiveContains(searchText) ?? false
                let bodyMatches = item.body?.localizedCaseInsensitiveContains(searchText) ?? false
                return headerMatches || bodyMatches
            }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Filter Chips Row
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(SearchFilter.allCases) { filter in
                            Button(action: {
                                withAnimation {
                                    selectedFilter = filter
                                    searchText = "" // Reset search when switching filter
                                }
                            }) {
                                Text(filter.rawValue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(filter == selectedFilter ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                    )
                            }
                            .foregroundColor(filter == selectedFilter ? .blue : .primary)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
                
                // Search Bar
                TextField("Search \(selectedFilter.rawValue.lowercased())", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.vertical, 4)
                
                // Search Results List
                List {
                    if selectedFilter == .lists {
                        ForEach(filteredLists) { meta in
                            Button(action: {
                                print("Selected list: \(meta.title)") // Debugging print
                                selectedListModel = OTDListModel(metadata: meta)
                                showEditListView = true
                            }) {
                                Text(meta.title)
                                    .padding(.vertical, 4)
                            }
                        }
                    } else {
                        ForEach(filteredItems, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.header ?? "No Header")
                                    .font(.headline)
                                if let body = item.body {
                                    Text(body)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Search")
            // Open EditListView as a full-screen takeover
            .fullScreenCover(isPresented: Binding(
                get: { showEditListView && selectedListModel != nil },
                set: { newValue in
                    if !newValue { showEditListView = false }
                }
            )) {
                if let listModel = selectedListModel {
                    EditListView(listModel: listModel, isPresented: $showEditListView)
                        .environmentObject(userModel)
                        .onDisappear {
                            selectedListModel = nil // Ensure reset when dismissed
                        }
                } else {
                    Text("Error loading list").onAppear {
                        print("⚠️ selectedListModel is nil, fullScreenCover should not be presented!")
                    }
                }
            }
        }
    }
}
