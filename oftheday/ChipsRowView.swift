import SwiftUI

// MARK: - Chips Row View

struct ChipsRowView: View {
    @Binding var selectedIndex: Int
    let lists: [OTDList]
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(Array(lists.enumerated()), id: \.offset) { index, list in
                        if list.isVisible {
                            Button(action: {
                                selectedIndex = index
                                // Scroll to the selected chip
                                withAnimation {
                                    scrollProxy.scrollTo(index, anchor: .center)
                                }
                            }) {
                                Text(list.title)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(selectedIndex == index ?
                                                  Color.blue.opacity(0.2) :
                                                  Color.gray.opacity(0.2))
                                    )
                            }
                            .foregroundColor(selectedIndex == index ? .blue : .primary)
                            .id(index) // Set the ID for scrolling
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedIndex) { oldValue, newValue in
                // Scroll to the new index whenever selectedIndex changes
                withAnimation {
                    scrollProxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
}
