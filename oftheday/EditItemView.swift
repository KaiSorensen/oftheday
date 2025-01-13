//
//  EditItemView.swift
//  oftheday
//
//  Created by user268370 on 1/12/25.
//

import SwiftUI

// MARK: - Edit Item View

/// A simple view to edit one OTDItem (title + body).
/// For now, we won't worry about images; that can come later.
struct EditItemView: View {
    @Binding var item: OTDItem
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $item.header)
                }
                
                Section(header: Text("Body")) {
                    TextEditor(text: $item.body)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button(action: {
                    // Save changes and dismiss
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "checkmark")
                }
            )
        }
    }
}
