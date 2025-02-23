////
////  OTDItemView.swift
////  oftheday
////
////  Created by Kai Sorensen on 2/22/25.
////
//
//
//import SwiftUI
//
//import SwiftUI
//
//struct OTDItemPreview: View {
//    let item: OTDItem
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(item.content)
//                .font(.body)
//                .lineLimit(2)
//                .foregroundColor(.primary)
//            Spacer(minLength: 4)
//            Text(item.updatedDate, style: .date)
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 8)
//                        .fill(Color(.secondarySystemBackground)))
//    }
//}
//
//struct OTDItemView: View {
//    @Binding var item: OTDItem
//    // Callback to trigger duplication (the parent can prompt for a target list).
//    var onDuplicate: ((OTDItem) -> Void)? = nil
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        VStack {
//            TextEditor(text: $item.content)
//                .padding()
//                .font(.body)
//                .onChange(of: item.content) { _ in
//                    item.updatedDate = Date()
//                }
//            Spacer()
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            // Done button dismisses the view and saves changes.
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Done") {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            }
//            // Duplicate option via a menu.
//            ToolbarItem(placement: .navigationBarLeading) {
//                Menu {
//                    Button("Duplicate to Another List") {
//                        onDuplicate?(item)
//                    }
//                } label: {
//                    Image(systemName: "square.on.square")
//                }
//            }
//        }
//    }
//}
