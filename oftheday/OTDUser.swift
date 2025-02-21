//
//  OTDUser.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/19/25.
//

import SwiftUI

let diskGroup = "group.com.kai.oftheday"

struct OTDFolder: Codable, Identifiable {
    var id = UUID()
    var name: String
    var folders: [UUID] = []
    var lists: [UUID] = []
    
    mutating func addList(_ listID: UUID) {
        lists.append(listID)
    }
    
    mutating func removeList(_ listID: UUID) {
        if let index = lists.firstIndex(of: listID) {
            lists.remove(at: index)
        }
    }
    
    mutating func addFolder(_ folderID: UUID) {
        folders.append(folderID)
    }
    
    mutating func removeFolder(_ folderID: UUID) {
        if let index = folders.firstIndex(of: folderID) {
            folders.remove(at: index)
        }
    }
}

struct OTDUser: Codable, Identifiable {
    var id = UUID()
    var name: String = ""
    var profilePic: String? = nil
    
    // user's data
    var lists: [OTDListMetadata] = []
    var currentTodayList: Int = 0
    var todayLists: [Int] = []
    var folders: [OTDFolder] = []

    func getName() -> String {
        return name.isEmpty ? "User" : name
    }
    
    mutating func addFolder(_ folder: OTDFolder) {
        folders.append(folder)
    }
    
    mutating func removeFolder(_ folder: OTDFolder) {
        // Find the folder index
        if let index = folders.firstIndex(where: { $0.id == folder.id }) {
            // Ensure the folder is empty before removing
            if folders[index].lists.isEmpty {
                folders.remove(at: index)
            } else {
                print("Cannot remove folder that contains lists.")
            }
        }
    }
    
    mutating func addList(_ list: OTDListMetadata) {
        lists.append(list)
        if list.today {
            todayLists.append(lists.count - 1)
        }
    }
    
    mutating func removeList(_ list: OTDListMetadata) {
        if let index = lists.firstIndex(of: list) {
            lists.remove(at: index)
            todayLists.removeAll { $0 == index }
            updateTodayLists()
        }
    }
    
    mutating func updateTodayLists() {
        todayLists = []
        
        for i in 0..<self.lists.count {
            if self.lists[i].today {
                todayLists.append(i)
            }
        }
        
        if currentTodayList < 0 || currentTodayList >= todayLists.count {
            currentTodayList = 0
            print("resetting currentTodayList because there's no logic to increment/decrement it when switching list's to/from today")
        }
    }
    
    mutating func nextList() {
        guard !todayLists.isEmpty else { return } // Prevent division by zero
        //        self.updateTodayLists()
        currentTodayList = (currentTodayList + 1) % todayLists.count
        print("today list (current: \(currentTodayList)): ")
        for i in todayLists {
            print("\(i): \(lists[i].title)")
        }
    }

    mutating func prevList() {
        guard !todayLists.isEmpty else { return } // Prevent division by zero
        currentTodayList = (currentTodayList - 1 + todayLists.count) % todayLists.count
        print("today list (current: \(currentTodayList)): ")
        for i in todayLists {
            print("\(i): \(lists[i].title)")
        }
    }
    
    func getCurrentListMetaData() -> OTDListMetadata? {
//        guard(todayLists.count > 0) else {return nil}
//        print("index in todaylists: \(currentTodayList)")
//        print("today lists length: \(todayLists.count)")
//        print("current list's index is \(todayLists[currentTodayList])")
        let currentListMetadata = lists[todayLists[currentTodayList]]
        return currentListMetadata
    }
    
    mutating func setCurrentList(byUUID uuid: UUID) {
        // Find the index of the given UUID in the todayLists array
        if let index = todayLists.firstIndex(where: { lists[$0].id == uuid }) {
            currentTodayList = index
        } else {
            print("UUID not found in today's lists.")
        }
    }
    
}

// Minimal view model that manages the current user.
class OTDUserModel: ObservableObject {
    
    @Published var currentUser: OTDUser? = nil
    
    init() {
        // Attempt to load the current user from the shared UserDefaults.
        if let data = UserDefaults(suiteName: diskGroup)?.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(OTDUser.self, from: data) {
            self.currentUser = user
        }
    }
    
    func saveUser(_ user: OTDUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults(suiteName: diskGroup)?.set(encoded, forKey: "currentUser")
            self.currentUser = user
        }
        print("saved user")
    }
    
    func loadDefaults() {
        guard let user = currentUser else {
            print("Failed to load defaults, user not found")
            return
        }

        var mutableUser = user // Create a mutable copy

        var quotesMeta = OTDListMetadata(owner: mutableUser.id, title: "Quotes", today: true)
        var insightsMeta = OTDListMetadata(owner: mutableUser.id, title: "Insights")
        var poemsMeta = OTDListMetadata(owner: mutableUser.id, title: "Poems", today: true)

        quotesMeta.itemsID = quotesMeta.id.uuidString + ".items"
        insightsMeta.itemsID = insightsMeta.id.uuidString + ".items"
        poemsMeta.itemsID = poemsMeta.id.uuidString + ".items"

        // Save default list items to UserDefaults
        let defaults = UserDefaults(suiteName: diskGroup)
        
        if let encoded = try? JSONEncoder().encode(quotesList()) {
            defaults?.set(encoded, forKey: quotesMeta.itemsID)
        }
        if let encoded = try? JSONEncoder().encode(insightsList()) {
            defaults?.set(encoded, forKey: insightsMeta.itemsID)
        }
        if let encoded = try? JSONEncoder().encode(poemsList()) {
            defaults?.set(encoded, forKey: poemsMeta.itemsID)
        }

        // Add lists to user
        mutableUser.addList(quotesMeta)
        mutableUser.addList(insightsMeta)
        mutableUser.addList(poemsMeta)

        // Create folders and assign lists
        mutableUser.addFolder(OTDFolder(name: "Some Words From Kai"))
        mutableUser.folders[0].lists.append(insightsMeta.id)
        mutableUser.folders[0].lists.append(poemsMeta.id)

        mutableUser.addFolder(OTDFolder(name: "Onward and Upward"))
        mutableUser.folders[1].lists.append(quotesMeta.id)

        print("Loaded defaults")
        saveUser(mutableUser) // Persist changes
    }
    
    func getUsername() -> String {
        return currentUser?.getName() ?? "no user"
    }
    
    func getFolders() -> [OTDFolder] {
        return currentUser?.folders ?? []
    }
    
    func addFolderToUser(_ name: String) {
        guard let user = currentUser else { return } // Ensure user exists
        var mutableUser = user // Create a mutable copy
        let newFolder = OTDFolder(name: name)
        mutableUser.addFolder(newFolder) // Modify the copy
        saveUser(mutableUser) // Save the modified user
    }
    
    func removeFolderToUser(_ folder: OTDFolder) {
        guard var mutableUser = currentUser else { return } // Ensure user exists

        // Find the folder in the user's folder list
        if let index = mutableUser.folders.firstIndex(where: { $0.id == folder.id }) {
            // Prevent deletion if folder is not empty
            if mutableUser.folders[index].lists.isEmpty {
                mutableUser.folders.remove(at: index)
                saveUser(mutableUser) // Save updated user data
            } else {
                print("Cannot remove folder that contains lists.")
            }
        } else {
            print("Folder not found.")
        }
    }
    
    func addFolderToFolder(_ f1: OTDFolder, to f2: OTDFolder) {
//        guard let user = currentUser else { return } // Ensure user exists
//        var mutableUser = user // Create a mutable copy
//        let newFolder = OTDFolder(name: name)
//        mutableUser.addFolder(newFolder) // Modify the copy
//        saveUser(mutableUser) // Save the modified user
    }
    
    func removeFolderFromFolder(_ f1: OTDFolder, from f2: OTDFolder) {
//        guard var mutableUser = currentUser else { return }
//        
//        if let folder1 = mutableUser.folders.firstIndex(of: folder) {
//            mutableUser.folders.remove(at: index)
//            saveUser(mutableUser) 
//        } else {
//            
//        }
    }
    
    func getMetasInFolder(for folder: OTDFolder) -> [OTDListMetadata] {
        guard let user = currentUser else { return [] } // Return empty array if user is nil
        return user.lists.filter { folder.lists.contains($0.id) }
    }
    
    func getMetasToday() -> [OTDListMetadata] {
        guard let user = currentUser else { return []} // Ensure user exists
                        
        var metas: [OTDListMetadata] = []
        for i in 0..<user.lists.count {
            if user.lists[i].today {
                metas.append(user.lists[i])
            }
        }
        
        return metas
    }
    
    func getCurrentListModel() -> OTDListModel? {
        guard let user = currentUser, getMetasToday().count > 0, let currentListMetadata = user.getCurrentListMetaData() else { return nil }
        return OTDListModel(metadata: currentListMetadata)
    }
    
    func getNextListModel() -> OTDListModel? {
        guard var user = currentUser else { return nil }
        user.updateTodayLists()
        user.nextList() // Modify the actual user
        saveUser(user) // Persist the change to currentUser
        
        if let nextListMetadata = user.getCurrentListMetaData() {
            return OTDListModel(metadata: nextListMetadata)
        } else {
            return nil
        }
    }

    func getPrevListModel() -> OTDListModel? {
        guard var user = currentUser else { return nil }
        user.updateTodayLists()
        user.prevList() // Modify the actual user
        saveUser(user) // Persist the change to currentUser

        if let prevListMetadata = user.getCurrentListMetaData() {
            return OTDListModel(metadata: prevListMetadata)
        } else {
            return nil
        }
    }
    
    func setCurrentList(_ metauuid: UUID) {
        guard var user = currentUser else { return }
        user.setCurrentList(byUUID: metauuid)
        saveUser(user)
    }
    
    func updateTodayFlag(for listID: UUID, to value: Bool) {
        guard var user = currentUser else { return }
        if let index = user.lists.firstIndex(where: { $0.id == listID }) {
            user.lists[index].today = value
            if (value == true ) { //for readability
                user.todayLists.append(index)
            } else {
                user.todayLists.removeAll(where: {$0 == index})
            }
            user.updateTodayLists()
            saveUser(user)
        }
    }
    
}
