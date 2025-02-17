//
//  AppIntents.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/16/25.
//

import AppIntents
import WidgetKit

// MARK: - OTDListEntity (AppEntity for Selection)

/// Represents a selectable list for the widget's configuration.
struct OTDListEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "OTD List"
    }

    var id: UUID
    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }

    static var defaultQuery = OTDListQuery()
}

// MARK: - OTDListQuery (Fetching List Options)

/// Provides the available lists from UserDefaults for widget configuration.
struct OTDListQuery: EntityQuery {
    
    func entities(for identifiers: [UUID]) async throws -> [OTDListEntity] {
        let allLists = try await fetchAllLists()
        return allLists.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [OTDListEntity] {
        return try await fetchAllLists()
    }

    /// Fetches the stored lists from the shared UserDefaults.
    private func fetchAllLists() async throws -> [OTDListEntity] {
        guard let userDefaults = UserDefaults(suiteName: "group.com.kai.oftheday"),
              let data = userDefaults.data(forKey: "OTDAllLists"),
              let allLists = try? JSONDecoder().decode(OTDAllLists.self, from: data) else {
            return []
        }

        return allLists.lists.map { OTDListEntity(id: $0.id, title: $0.title) }
    }
}

// MARK: - OTDWidgetConfigurationIntent

/// Configurable intent for selecting which OTD List to display in the widget.
struct OTDWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select OTD List"
    static var description = IntentDescription("Choose which 'Of The Day' list to display.")

    @Parameter(
        title: "OTD List",
        default: OTDListEntity(id: UUID(), title: "Default List")
    )
    var selectedList: OTDListEntity?
}
