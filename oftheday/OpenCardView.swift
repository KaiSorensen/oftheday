//
//  OpenCardView.swift
//  oftheday
//
//  Created by Kai Sorensen on 1/27/25.
//

import SwiftUI

struct OpenCardView: View {
    // Binding to show/dismiss this view
    @Binding var isPresented: Bool
    
    let item: OTDItem

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Full Title
                        Text(item.header ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, 20)
                        
                        // Full Body
                        Text(item.body ?? "")
                            .font(.body)
                    }
                    .frame(minHeight: geometry.size.height) // Centers content vertically
                    .padding(.horizontal, 16)
                }
            }
        }
        .onTapGesture {
            // Close fullscreen view by tapping anywhere
            isPresented = false            
        }
    }
}
