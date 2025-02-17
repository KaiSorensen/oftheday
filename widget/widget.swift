//
//  widget.swift
//  widget
//
//  Created by Kai Sorensen on 2/16/25.
//
import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Provider

struct Provider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        let sampleIntent = OTDWidgetConfigurationIntent()
        sampleIntent.selectedList?.title = "Default"
        return SimpleEntry(
            date: Date(),
            configuration: sampleIntent,
            item: OTDItem(header: "Sample Header", body: "Sample Body", imageReference: nil)
        )
    }
    
    func snapshot(for configuration: OTDWidgetConfigurationIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: configuration,
            item: loadCurrentItem(using: configuration)
        )
    }
    
    func timeline(for configuration: OTDWidgetConfigurationIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        // Generate entries every 15 minutes for the next hour.
        for minuteOffset in stride(from: 0, to: 60, by: 15) {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                configuration: configuration,
                item: loadCurrentItem(using: configuration)
            )
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
    
    /// Loads the current OTDItem from the selected list in shared UserDefaults.
    private func loadCurrentItem(using configuration: OTDWidgetConfigurationIntent) -> OTDItem {
        guard let userDefaults = UserDefaults(suiteName: "group.com.kai.oftheday"),
              let data = userDefaults.data(forKey: "OTDAllLists"),
              let allLists = try? JSONDecoder().decode(OTDAllLists.self, from: data)
        else {
            return OTDItem(header: "No Data", body: "Unable to load lists", imageReference: nil)
        }
        
        // Determine the list selected in the widget’s configuration; if not found, default to the app’s current list.
        let selectedList = allLists.lists.first(where: { $0.title == configuration.selectedList?.title }) ?? allLists.lists.first
        
        guard let list = selectedList,
              !list.items.isEmpty,
              list.itemOrder.indices.contains(list.currentItem)
        else {
            return OTDItem(header: "No Item", body: "No items available", imageReference: nil)
        }
        
        let itemIndex = list.itemOrder[list.currentItem]
        if list.items.indices.contains(itemIndex) {
            return list.items[itemIndex]
        } else {
            return OTDItem(header: "Invalid Item", body: "Item index out of range", imageReference: nil)
        }
    }
}

// MARK: - Timeline Entry

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: OTDWidgetConfigurationIntent
    let item: OTDItem
}

// MARK: - Widget View

struct WidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.item.header ?? "No Header")
                .font(.headline)
            Text(entry.item.body ?? "No Content")
                .font(.subheadline)
            // If an image reference is provided and a corresponding image exists in your asset catalog:
            if let imageRef = entry.item.imageReference,
               let uiImage = UIImage(named: imageRef) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct OTDWidget: Widget {
    let kind: String = "OTDWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: OTDWidgetConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Of The Day Widget")
        .description("Displays the current item from your selected list.")
    }
}

// MARK: - Preview

//#Preview(as: .systemSmall) {
//    OTDWidget()
//} timeline: {
//    let sampleIntent = OTDWidgetConfigurationIntent()
//    sampleIntent.listTitle = "Default"
//    SimpleEntry(
//        date: .now,
//        configuration: sampleIntent,
//        item: OTDItem(header: "Sample", body: "This is a sample OTDItem", imageReference: nil)
//    )
//}
