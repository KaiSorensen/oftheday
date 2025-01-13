//
//  CardView.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//

import SwiftUI

// MARK: - Card View

struct CardView: View {
    let item: OTDItem
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
            
            VStack {
                // Title in top-left
                HStack {
                    Text(item.header ?? "")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 16)
                        .padding(.leading, 16)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Body in the center
                Text(item.body ?? "")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 16)
                
                Spacer()
            }
        }
    }
}
