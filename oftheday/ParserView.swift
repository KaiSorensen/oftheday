import SwiftUI

// Bound-exclusive range overlap comparison
extension NSRange {
    func overlapsExclusive(_ other: NSRange) -> Bool {
        let selfStart = self.location
        let selfEnd = self.location + self.length
        let otherStart = other.location
        let otherEnd = other.location + other.length

        return selfStart < otherEnd - 1 && otherStart < selfEnd - 1
    }
}

struct ParserView: View {
    @Binding var isPresented: Bool

    @State private var text: String = ""
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @State private var attributedText: NSAttributedString? = nil
    @State private var oranges: [NSRange] = []
    @State private var blues: [NSRange] = []
    @State private var currentHighlight: NSRange? = nil

    var body: some View {
        NavigationStack {
            VStack {
                CustomTextEditor(
                    text: $text,
                    attributedText: $attributedText,
                    selectedRange: $selectedRange,
                    placeholder: "Paste text here"
                )
                .frame(maxHeight: .infinity)
                .cornerRadius(10)
                .onChange(of: selectedRange) { newRange in
                    let blueIndex = isCursorInBlue()
                    let orangeIndex = isCursorInOrange()
                    
                    if currentHighlight != nil && !(currentHighlight?.contains(selectedRange.location))! {
                        currentHighlight = nil
                    }
                    if currentHighlight == nil && blueIndex >= 0 {
                        currentHighlight = blues[blueIndex]
                        setSelectionRange(currentHighlight!)
                    }
                    if currentHighlight == nil && orangeIndex >= 0 {
                        currentHighlight = oranges[orangeIndex]
                        setSelectionRange(currentHighlight!)
                    }
                }
                
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

                Button("Highlight Blue") {
                    highlightBlue()
                }
                Button("Highlight Orange") {
                    highlightOrange()
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
    func removeOverlaps(_ highlight: NSRange) {
        // Check for overlap
        for index in (0..<oranges.count).reversed() { // .reversed in case we need to remove an item
            if oranges[index].overlapsExclusive(highlight) {
                oranges.remove(at: index)
                print("orange overlap")
            }
        }
        for index in (0..<blues.count).reversed() { // .reversed in case we need to remove an item
            if blues[index].overlapsExclusive(highlight) {
                blues.remove(at: index)
                print("blue overlap")
            }
        }
    }
    private func highlightOrange() {
        guard isTextSelected() else {
            print("No text selected")
            return
        }
        
        let highlight = selectedRange
        
        // Check for overlap
        removeOverlaps(highlight)
        
        oranges.append(highlight)
        
        
        updateHighlights()
    }
    private func highlightBlue() {
        guard isTextSelected() else {
            print("No text selected")
            return
        }
        
        let highlight = selectedRange

        removeOverlaps(highlight)
        
        blues.append(highlight)
        
        updateHighlights()
    }
    private func updateHighlights() {
        // Define the base attributes to match the text view's styling.
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.label
        ]
        
        let mutableAttrString = NSMutableAttributedString(string: text, attributes: baseAttributes)
        
        // Apply the orange color highlights
        for index in (0..<oranges.count).reversed() { // .reversed in case we need to remove an item
            if oranges[index].location + oranges[index].length > text.count {
                oranges.remove(at: index)
            } else {
                mutableAttrString.addAttribute(.backgroundColor, value: UIColor.systemOrange, range: oranges[index])
            }
        }
        
        // Apply the blue color highlights
        for index in (0..<blues.count).reversed() { // .reversed in case we need to remove an item
            if blues[index].location + blues[index].length > text.count {
                blues.remove(at: index)
            } else {
                mutableAttrString.addAttribute(.backgroundColor, value: UIColor.systemBlue, range: blues[index])
            }
        }
        
        // Update the binding that our custom editor uses.
        attributedText = mutableAttrString // ?? inefficient, should just bodify attributedText directly
    }
    func isCursorInBlue() -> Int {
        var i = -1
        for index in 0..<blues.count {
            if (selectedRange.location >= blues[index].lowerBound) && (selectedRange.location <= blues[index].upperBound) {
                i = index
            }
        }
        return i
    }
    func isCursorInOrange() -> Int {
        var i = -1
        for index in 0..<oranges.count {
            if (selectedRange.location >= oranges[index].lowerBound) && (selectedRange.location <= oranges[index].upperBound) {
                i = index
            }
        }
        return i
    }
}

// MARK: - CustomTextEditor with Attributed Text Support

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var attributedText: NSAttributedString?
    @Binding var selectedRange: NSRange
    var placeholder: String

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor

        init(parent: CustomTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // Update the plain text binding from the UITextView.
            parent.text = textView.text
            // Reset attributed text once the user edits.
            parent.attributedText = nil
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
            // Remove placeholder when editing begins.
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            // Restore placeholder if text is empty.
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.lightGray
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.backgroundColor = UIColor.secondarySystemBackground
        textView.font = UIFont.systemFont(ofSize: 18)

        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.layer.cornerRadius = 10

        if let attrText = attributedText {
            // If an attributed text exists, display it.
            textView.attributedText = attrText
        } else {
            // Otherwise, use plain text (or placeholder if empty).
            textView.text = text.isEmpty ? placeholder : text
            textView.textColor = text.isEmpty ? UIColor.lightGray : UIColor.label
        }

        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if let attrText = attributedText {
            // If an attributed text is set, update the UITextView.
            textView.attributedText = attrText
            // Also update the plain text binding.
            DispatchQueue.main.async {
                self.text = attrText.string
            }
        } else {
            // Use plain text as usual.
            if text.isEmpty && !textView.isFirstResponder {
                textView.text = placeholder
                textView.textColor = UIColor.lightGray
            } else if textView.text != text {
                textView.text = text
                textView.textColor = UIColor.label
            }
        }
        
        // Ensure the selection range remains valid.
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
