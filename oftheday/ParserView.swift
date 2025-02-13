import SwiftUI

// Bound-exclusive range overlap comparison
extension NSRange {
    func overlap(_ other: NSRange) -> Int {
        let selfStart = self.location
        let selfEnd = self.location + self.length
        let otherStart = other.location
        let otherEnd = other.location + other.length

        if selfEnd == otherStart || otherEnd == selfStart {
            return 0 // They are touching
        }

        let overlap = max(0, min(selfEnd, otherEnd) - max(selfStart, otherStart))

        return overlap > 0 ? overlap : -1
    }
}

struct ParserView: View {
    @Binding var isPresented: Bool
    
    @State private var text: String = ""
    @State private var selectedRange = NSRange(location: 0, length: 0)
    @State private var previousRange = NSRange(location: 0, length: 0)
    @State private var attributedText: NSAttributedString? = nil
    
    @State private var blues: [NSRange] = []
    @State private var oranges: [NSRange] = []
    @State private var cursorInBlue: Int = -1
    @State private var cursorInOrange: Int = -1
    
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
                .onChange(of: selectedRange) { oldRange, newRange in
                    previousRange = oldRange
                    selectedRange = newRange
                    
                    
                    isCursorInBlue()
                    isCursorInOrange()
                }
                .onChange(of: text) { oldText, newText in
                    let oldLen = oldText.count
                    let newLen = newText.count
                    let lenDiff = newLen - oldLen
                    
                    print("cursor position \(selectedRange.location)")
                    
                    // ?? this would all work better with an "overlap" function that calculates exact overlap, and could also be used in the isCursorIn- functions
                                        
                    // adjust blue highlight positions upon editing text
                    if blues.count > 0 {
                        
                        
                        for index in 0..<blues.count {
                            var locationDiff = blues[index].location - previousRange.location
                            print("location diff: \(locationDiff)")
                            
                            if (locationDiff >= 0) { // if the cursor was before the highlight
                                let overlap = previousRange.length - locationDiff
                                print("overlap: \(overlap)")
                                
                                
                                if overlap > 0 && lenDiff < 0 { // if a selection was deleted within highlight
                                    blues[index].location -= locationDiff
                                    blues[index].length -= overlap
                                    print("new blue: {\(blues[index].location) , \(blues[index].length)}")
                                } else { // if no selection, then cursor was not within highlight
                                    blues[index].location += lenDiff
                                    print("moved blue: {\(blues[index].location) , \(blues[index].length)}")
                                }
                            }
                            else if (locationDiff < 0) { //if the cursor was after the highlight
                                locationDiff = abs(locationDiff)
                                let overlap = blues[index].upperBound - previousRange.lowerBound
                                
                                print("overlap: \(overlap)")
                                
                                if lenDiff < 0 && previousRange.upperBound >= blues[index].upperBound && overlap > 0 { // if a selection was deleted that overlapped the end of the highlight
                                    blues[index].length -= overlap
                                    print("new blue: {\(blues[index].location) , \(blues[index].length)}")
                                    
                                } else if (locationDiff <= blues[index].length) { // then if edits were made entirely within the highlight
                                    blues[index].length += lenDiff
                                    print("new blue: {\(blues[index].location) , \(blues[index].length)}")
                                    
                                } // else do nothing, highlight is unaffected
                            }
                            if (blues[index].length <= 0) {
                                blues.remove(at: index)
                            }
                        }
                    }
                    
                    // adjust orange highlight positions upon editing text
                    if oranges.count > 0 {
                        
                        for index in 0..<oranges.count {
                            var locationDiff = oranges[index].location - previousRange.location
                            print("location diff: \(locationDiff)")
                            
                            if (locationDiff >= 0) { // if the cursor was before the highlight
                                let overlap = previousRange.length - locationDiff
                                print("overlap: \(overlap)")
                                
                                
                                if overlap > 0 && lenDiff < 0 { // if a selection was deleted within highlight
                                    oranges[index].location -= locationDiff
                                    oranges[index].length -= overlap
                                    print("new orange: {\(oranges[index].location) , \(oranges[index].length)}")
                                } else { // if no selection, then cursor was not within highlight
                                    oranges[index].location += lenDiff
                                    print("moved orange: {\(oranges[index].location) , \(oranges[index].length)}")
                                }
                            }
                            else if (locationDiff < 0) { //if the cursor was after the highlight
                                locationDiff = abs(locationDiff)
                                let overlap = oranges[index].upperBound - previousRange.lowerBound
                                
                                print("overlap: \(overlap)")
                                
                                if lenDiff < 0 && previousRange.upperBound >= oranges[index].upperBound && overlap > 0 { // if a selection was deleted that overlapped the end of the highlight
                                    oranges[index].length -= overlap
                                    print("new orange: {\(oranges[index].location) , \(oranges[index].length)}")
                                    
                                } else if (locationDiff <= oranges[index].length) { // then if edits were made entirely within the highlight
                                    oranges[index].length += lenDiff
                                    print("new orange: {\(oranges[index].location) , \(oranges[index].length)}")
                                    
                                } // else do nothing, highlight is unaffected
                            }
                            if (oranges[index].length <= 0) {
                                oranges.remove(at: index)
                            }
                        }
                    }
                    updateHighlights()
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
                
                Button(cursorInBlue >= 0 ? "Remove Blue" : "Highlight Blue") {
                    if cursorInBlue >= 0 {
                        removeBlue(at: cursorInBlue)
                        isCursorInBlue()
                    } else {
                        highlightBlue()
                    }
                }
                Button(cursorInOrange >= 0 ? "Remove Orange" : "Highlight Orange") {
                    if cursorInOrange >= 0 {
                        removeOrange(at: cursorInOrange)
                        isCursorInOrange()
                    } else {
                        highlightOrange()
                    }
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
        // Check for overlaps, empties, and juxtapositions
        for index in (0..<oranges.count).reversed() { // .reversed in case we need to remove an item
            if oranges[index].overlap(highlight) > 0 {
                oranges.remove(at: index)
                print("orange overlap")
            }
        }
        for index in (0..<blues.count).reversed() { // .reversed in case we need to remove an item
            if blues[index].overlap(highlight) > 0 {
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
        
        isCursorInOrange()
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
        
        isCursorInBlue()
        updateHighlights()
    }
    private func updateHighlights() {
        
        // DONT FORGET TO COMBINE HIGHLIGHTS IF THEY'RE TOUCHING, OR REMOVE IF EMPTY
        
        
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
    //updates state variable
    func isCursorInBlue() {
        var i = -1
        for index in 0..<blues.count {
            if (selectedRange.location >= blues[index].lowerBound) && (selectedRange.location <= blues[index].upperBound) {
                i = index
            }
        }
        print("cursor in blue[\(i)]")
        cursorInBlue = i
    }
    //updates state variable
    func isCursorInOrange() {
        var i = -1
        for index in 0..<oranges.count {
            if (selectedRange.location >= oranges[index].lowerBound) && (selectedRange.location <= oranges[index].upperBound) {
                i = index
            }
        }
        print("cursor in orange[\(i)]")
        cursorInOrange = i
    }
    func removeBlue (at index: Int) {
        blues.remove(at: index)
        updateHighlights()
    }
    func removeOrange(at index: Int) {
        oranges.remove(at: index)
        updateHighlights()
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
