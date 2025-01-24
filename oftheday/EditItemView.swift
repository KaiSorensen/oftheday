import SwiftUI

struct EditItemView: View {
    /// The OTDItem we’re editing or creating
    @Binding var item: OTDItem
    
    /// Indicates if the user confirmed the action
    @Binding var didConfirm: Bool
    
    /// For dismissing this page (sheet)
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                // Optional Header
                Section(header: Text("Title")) {
                    TextField("Optional Title",
                              text: Binding(
                                get: { item.header ?? "" },
                                set: { item.header = $0.isEmpty ? nil : $0 }
                              )
                    )
                }
                
                // Optional Body
                Section(header: Text("Body")) {
                    TextEditor(text: Binding(
                        get: { item.body ?? "" },
                        set: { item.body = $0.isEmpty ? nil : $0 }
                    ))
                    .frame(minHeight: 120)
                }
                
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // User pressed confirm
                        didConfirm = true
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}
