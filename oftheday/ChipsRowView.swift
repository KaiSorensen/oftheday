//
//  ChipsRowView.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//
import SwiftUI

// MARK: - Chips Row View

struct ChipsRowView: View {
    @Binding var selectedIndex: Int
    let lists: [OTDList]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(lists.enumerated()), id: \.offset) { index, list in
                    if list.isVisible {
                        Button(action: {
                            selectedIndex = index
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
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
