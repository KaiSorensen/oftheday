import SwiftUI

// MARK: - Chips Row View

struct ChipsRowView: View {
    @ObservedObject var userModel: OTDUserModel
    let lists: [OTDListMetadata]
    @Binding var listModel: OTDListModel?
    @Binding var currentItem: OTDItem?
    
    @State private var showListView: Bool = false

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    HStack {
                        ForEach(lists) { meta in
                            if meta.today {
                                Button(action: {
                                    if let currentList = listModel, currentList.metadata.id == meta.id {
                                        // Chip pressed for the already selected list
                                        showListView = true
                                    } else {
                                        let newListModel = OTDListModel(metadata: meta)
                                        listModel = newListModel
                                        userModel.setCurrentList(meta.id)
                                        currentItem = newListModel.getCurrentItem()
                                        withAnimation {
                                            scrollProxy.scrollTo(meta.id, anchor: .center)
                                        }
                                    }
                                }) {
                                    Text(meta.title)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(meta.id == listModel?.metadata.id ?
                                                      Color.blue.opacity(0.2) :
                                                      Color.gray.opacity(0.2))
                                        )
                                }
                                .foregroundColor(meta.id == listModel?.metadata.id ? .blue : .primary)
                                .id(meta.id) // Assign an ID for scroll tracking
                            }
                        }
                    }
                    Spacer()
                }
                .frame(minWidth: UIScreen.main.bounds.width)
            }
            .frame(height: 40) // Constrained height
            .onChange(of: listModel?.metadata.id) { _, newId in
                if let newId = newId {
                    withAnimation {
                        scrollProxy.scrollTo(newId, anchor: .center)
                    }
                }
            }
            // Present the EditListView as a full screen cover when needed
            .fullScreenCover(isPresented: $showListView) {
                if let listModel = listModel {
                    EditListView(listModel: listModel, isPresented: $showListView)
                        // Optionally, you can add a dismiss button within the EditListView
                        // or use an environment dismiss action.
                }
            }
        }
    }
}
