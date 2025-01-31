//
//  SettingsOverlay.swift
//  oftheday
//
//  Created by Kai Sorensen on 1/12/25.
//

import SwiftUI


// MARK: - Overlays

struct SettingsOverlay: View {
    @Binding var showOverlay: Bool
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    // Dismiss overlay if tapped outside
                    showOverlay = false
                }
            
            // Overlay container
            VStack {
                Text("Widget Settings")
                    .font(.title2)
                    .bold()
                    .padding()
                
                // Placeholder for future widget settings
                Text("Configure widget options here…")
                    .padding()
                
                Spacer()
                
                Button("Close") {
                    showOverlay = false
                }
                .padding()
            }
            .frame(maxWidth: 300, maxHeight: 300)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}


