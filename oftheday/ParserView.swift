import SwiftUI

struct ParserView: View {
    @Binding var isPresented: Bool

    @State private var text: String = ""
    @State private var selectedRange = NSRange(location: 0, length: 0)

    var body: some View {
        NavigationStack {
            VStack {
                CustomTextEditor(
                    text: $text,
                    selectedRange: $selectedRange,
                    placeholder: "Paste text here"
                )
                .frame(maxHeight: .infinity)
                .cornerRadius(10)
                
                Button("Get Cursor Location") {
                    print("Cursor Location: \(selectedRange.location)")
                }

                Button("Get Selection Range") {
                    print("Selection Range: \(selectedRange)")
                }

                Button("Select Text (Range 5-10)") {
                    setSelectionRange(NSRange(location: 5, length: 5))
                }

                Button("Is Text Selected?") {
                    let isSelected = isTextSelected()
                    print("Text Selected: \(isSelected)")
                }

                Button("Unfocus (like pressing Escape)") {
                    resignEditorFocus()
                }
            }
            .padding()
            .navigationTitle("Parser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }

    func isTextSelected() -> Bool {
        return selectedRange.length > 0
    }

    private func resignEditorFocus() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
        selectedRange = NSRange(location: 0, length: 0)
    }

    private func setSelectionRange(_ range: NSRange) {
        if range.location + range.length <= text.count {
            selectedRange = range
        }
    }
}

// MARK: - CustomTextEditor (Fixes Placeholder Issue)

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var selectedRange: NSRange
    var placeholder: String

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(parent: CustomTextEditor) {  // Fix: Correctly initialize parent reference
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            let maxLength = textView.text.count
            if textView.selectedRange.location != NSNotFound,
               textView.selectedRange.location >= 0,
               textView.selectedRange.location <= maxLength {
                parent.selectedRange = textView.selectedRange
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            // Remove placeholder when editing starts
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            // Restore placeholder only if text is empty and keyboard is dismissed
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)  // Fix: Ensure correct parent reference
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.font = UIFont.systemFont(ofSize: 18)

        // Mimic SwiftUI TextEditor
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.layer.cornerRadius = 10

        // Ensure correct placeholder behavior
        textView.text = text.isEmpty ? placeholder : text
        textView.textColor = text.isEmpty ? UIColor.lightGray : UIColor.label

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if text.isEmpty && !textView.isFirstResponder {
            // Show placeholder when field is empty and not in focus
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        } else if textView.text != text {
            // Sync text when not using placeholder
            textView.text = text
            textView.textColor = UIColor.label
        }

        // Ensure selection range stays within bounds
        let maxLength = textView.text.count
        if selectedRange.location != NSNotFound,
           selectedRange.location >= 0,
           selectedRange.location + selectedRange.length <= maxLength {
            textView.selectedRange = selectedRange
        } else {
            textView.selectedRange = NSRange(location: 0, length: 0)
        }
    }
}
