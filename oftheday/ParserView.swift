//import SwiftUI
//
//// Bound-exclusive range overlap comparison
//extension NSRange {
//    func overlap(_ other: NSRange) -> Int {
//        let selfStart = self.location
//        let selfEnd = self.location + self.length
//        let otherStart = other.location
//        let otherEnd = other.location + other.length
//        
//        if selfEnd == otherStart || otherEnd == selfStart {
//            return 0 // They are touching
//        }
//        
//        let overlap = max(0, min(selfEnd, otherEnd) - max(selfStart, otherStart))
//        
//        return overlap > 0 ? overlap : -1
//    }
//}
//
//struct ParserView: View {
//    @Binding var isPresented: Bool
//    @ObservedObject var viewModel: OTDViewModel
//    
//    @State private var text: String = ""
//    @State private var selectedRange = NSRange(location: 0, length: 0)
//    @State private var previousRange = NSRange(location: 0, length: 0)
//    @State private var attributedText: NSAttributedString? = nil
//    
//    @State private var blues: [NSRange] = [] // bodies
//    @State private var oranges: [NSRange] = [] //titles
//    
//    @State private var cursorInBlue: Int = -1
//    @State private var cursorInOrange: Int = -1
//    
//    @State private var parser: ItemParser? = nil
//    @State private var showParsed: Bool = false
//    @State private var parsedText: String = ""
//    @State private var parsedBlues: [NSRange] = []
//    @State private var parsedOranges: [NSRange] = []
//    
//    @State private var allowOnChange: Bool = true
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                CustomTextEditor(
//                    text: $text,
//                    attributedText: $attributedText,
//                    selectedRange: $selectedRange,
//                    placeholder: "Paste text here"
//                )
//                .frame(maxHeight: .infinity)
//                .cornerRadius(10)
//                .onChange(of: selectedRange) { oldRange, newRange in
//                    previousRange = oldRange
//                    selectedRange = newRange
//                    
//                    
//                    isCursorInBlue()
//                    isCursorInOrange()
//                }
//                .onChange(of: text) { oldText, newText in // OHHHH you only do this when showparsed is false
//                    if (!allowOnChange) {
//                        allowOnChange = true
//                        return
//                    }
//                    print("onChange proceeding")
//                    
//                    
//                    let oldLen = oldText.count
//                    let newLen = newText.count
//                    let lenDiff = newLen - oldLen
//                    
//                    //                    print("cursor position \(selectedRange.location)")
//                    
//                    // ?? this would all work better with an "overlap" function that calculates exact overlap, and could also be used in the isCursorIn- functions
//                    
//                    // adjust blue highlight positions upon editing text
//                    if blues.count > 0 {
//                        
//                        // ?? BUG: if the whole text is deleted at once, then all highlights should be removed... essentially, there needs to be a try catch that will remove all highlights if caught
//                        for index in 0..<blues.count {
//                            var locationDiff = blues[index].location - previousRange.location
//                            //                            print("location diff: \(locationDiff)")
//                            
//                            if (locationDiff >= 0) { // if the cursor was before the highlight
//                                let overlap = previousRange.length - locationDiff
//                                //                                print("overlap: \(overlap)")
//                                
//                                
//                                if overlap > 0 && lenDiff < 0 { // if a selection was deleted within highlight
//                                    blues[index].location -= locationDiff
//                                    blues[index].length -= overlap
//                                    //                                    print("new blue: {\(blues[index].location) , \(blues[index].length)}")
//                                } else { // if no selection, then cursor was not within highlight
//                                    blues[index].location += lenDiff
//                                    //                                    print("moved blue: {\(blues[index].location) , \(blues[index].length)}")
//                                }
//                            }
//                            else if (locationDiff < 0) { //if the cursor was after the highlight
//                                locationDiff = abs(locationDiff)
//                                let overlap = blues[index].upperBound - previousRange.lowerBound
//                                
//                                //                                print("overlap: \(overlap)")
//                                
//                                if lenDiff < 0 && previousRange.upperBound >= blues[index].upperBound && overlap > 0 { // if a selection was deleted that overlapped the end of the highlight
//                                    blues[index].length -= overlap
//                                    //                                    print("new blue: {\(blues[index].location) , \(blues[index].length)}")
//                                    
//                                } else if (locationDiff <= blues[index].length) { // then if edits were made entirely within the highlight
//                                    blues[index].length += lenDiff
//                                    //                                    print("new blue: {\(blues[index].location) , \(blues[index].length)}")
//                                    
//                                } // else do nothing, highlight is unaffected
//                            }
//                            if (blues[index].length <= 0) {
//                                blues.remove(at: index)
//                            }
//                        }
//                    }
//                    
//                    // adjust orange highlight positions upon editing text
//                    if oranges.count > 0 {
//                        
//                        for index in 0..<oranges.count {
//                            var locationDiff = oranges[index].location - previousRange.location
//                            //                            print("location diff: \(locationDiff)")
//                            
//                            if (locationDiff >= 0) { // if the cursor was before the highlight
//                                let overlap = previousRange.length - locationDiff
//                                //                                print("overlap: \(overlap)")
//                                
//                                
//                                if overlap > 0 && lenDiff < 0 { // if a selection was deleted within highlight
//                                    oranges[index].location -= locationDiff
//                                    oranges[index].length -= overlap
//                                    //                                    print("new orange: {\(oranges[index].location) , \(oranges[index].length)}")
//                                } else { // if no selection, then cursor was not within highlight
//                                    oranges[index].location += lenDiff
//                                    //                                    print("moved orange: {\(oranges[index].location) , \(oranges[index].length)}")
//                                }
//                            }
//                            else if (locationDiff < 0) { //if the cursor was after the highlight
//                                locationDiff = abs(locationDiff)
//                                let overlap = oranges[index].upperBound - previousRange.lowerBound
//                                
//                                //                                print("overlap: \(overlap)")
//                                
//                                if lenDiff < 0 && previousRange.upperBound >= oranges[index].upperBound && overlap > 0 { // if a selection was deleted that overlapped the end of the highlight
//                                    oranges[index].length -= overlap
//                                    //                                    print("new orange: {\(oranges[index].location) , \(oranges[index].length)}")
//                                    
//                                } else if (locationDiff <= oranges[index].length) { // then if edits were made entirely within the highlight
//                                    oranges[index].length += lenDiff
//                                    //                                    print("new orange: {\(oranges[index].location) , \(oranges[index].length)}")
//                                    
//                                } // else do nothing, highlight is unaffected
//                            }
//                            if (oranges[index].length <= 0) {
//                                oranges.remove(at: index)
//                            }
//                        }
//                    }
//                    updateHighlights()
//                }
//                
//                //                Button("Get Cursor Location") {
//                //                    print("Cursor Location: \(selectedRange.location)")
//                //                }
//                //
//                //                Button("Get Selection Range") {
//                //                    print("Selection Range: \(selectedRange)")
//                //                }
//                //
//                //                Button("Select Text (Range 5-10)") {
//                //                    setSelectionRange(NSRange(location: 5, length: 5))
//                //                }
//                //
//                //                Button("Is Text Selected?") {
//                //                    let isSelected = isTextSelected()
//                //                    print("Text Selected: \(isSelected)")
//                //                }
//                //
//                //                Button("Unfocus (like pressing Escape)") {
//                //                    resignEditorFocus()
//                //                }
//                Button (showParsed ? "Remove Auto-Filled" : "Auto-Fill Highlights") {
//                    if showParsed { // switching to not parsed-view
//                        print("exiting auto-fill")
//                        allowOnChange = false
//                        
//                        parser = nil
//                        
//                        text = parsedText
//                        parsedText = ""
//                        
//                        blues = parsedBlues
//                        parsedBlues = []
//                        
//                        oranges = parsedOranges
//                        parsedOranges = []
//                        
//                        
//                        updateHighlights()
//                        showParsed = false
//                    } else { // ?? arbitrary 6 here, need more sophisticated indication, Bool called parsable
//                        //                        print("entering auto-fill")
//                        showParsed = true
//                        allowOnChange = false
//                        
//                        
//                        let trim = trimText(originalText: text, originalBlues: blues, originalOranges: oranges)
//                        parsedText = trim.trimmedText
//                        parsedBlues = trim.trimmedBlues
//                        parsedOranges = trim.trimmedOranges
//                        
//                        parser = ItemParser(text: parsedText, blues: parsedBlues, oranges: parsedOranges)
//                        parser?.makeHighlights()
//                        parsedBlues = parser?.blues ?? []
//                        parsedOranges = parser?.oranges ?? []
//                        
//                        if (parsedBlues.count <= 0 && parsedOranges.count <= 0) { // funny bug: I originally put || here instead of && and it wouldn't work if there was only one highlight color :)
//                            print("parsing failed")
//                            parser = nil
//                        } else {
//                            
//                            let tempText = text
//                            text = parsedText
//                            parsedText = tempText
//                            
//                            let tempBlues = blues
//                            blues = parsedBlues
//                            parsedBlues = tempBlues
//                            
//                            let tempOranges = oranges
//                            oranges = parsedOranges
//                            parsedOranges = tempOranges
//                            
//                            updateHighlights()
//                        }
//                    }
//                }
//                
//                
//                Button(cursorInBlue >= 0 ? "Remove Blue" : "Highlight Blue") {
//                    if cursorInBlue >= 0 {
//                        removeBlue(at: cursorInBlue)
//                        isCursorInBlue()
//                    } else {
//                        highlightBlue()
//                    }
//                }
//                Button(cursorInOrange >= 0 ? "Remove Orange" : "Highlight Orange") {
//                    if cursorInOrange >= 0 {
//                        removeOrange(at: cursorInOrange)
//                        isCursorInOrange()
//                    } else {
//                        highlightOrange()
//                    }
//                }
//            }
//            .padding()
//            .navigationTitle("Parser")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        if (blues.count > 0 || oranges.count > 0) {
//                            addItemsToList()
//                        }
//                        isPresented = false
//                    } label: {
//                        if (blues.count > 0 || oranges.count > 0) {
//                            Image(systemName: "checkmark")
//                        } else {
//                            Image(systemName: "xmark")
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func isTextSelected() -> Bool {
//        return selectedRange.length > 0
//    }
//    
//    private func resignEditorFocus() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from: nil, for: nil)
//        selectedRange = NSRange(location: 0, length: 0)
//    }
//    
//    private func setSelectionRange(_ range: NSRange) {
//        if range.location + range.length <= text.count {
//            selectedRange = range
//        }
//    }
//    
//    func removeOverlaps(_ highlight: NSRange) {
//        // Check for overlaps, empties, and juxtapositions
//        for index in (0..<oranges.count).reversed() { // .reversed in case we need to remove an item
//            if oranges[index].overlap(highlight) > 0 {
//                oranges.remove(at: index)
//                print("orange overlap")
//            }
//        }
//        for index in (0..<blues.count).reversed() { // .reversed in case we need to remove an item
//            if blues[index].overlap(highlight) > 0 {
//                blues.remove(at: index)
//                print("blue overlap")
//            }
//        }
//    }
//    private func highlightOrange() {
//        guard isTextSelected() else {
//            print("No text selected")
//            return
//        }
//        
//        let highlight = selectedRange
//        
//        // Check for overlap
//        removeOverlaps(highlight)
//        
//        oranges.append(highlight)
//        
//        isCursorInOrange()
//        updateHighlights()
//    }
//    private func highlightBlue() {
//        guard isTextSelected() else {
//            print("No text selected")
//            return
//        }
//        
//        let highlight = selectedRange
//        
//        removeOverlaps(highlight)
//        
//        blues.append(highlight)
//        
//        isCursorInBlue()
//        updateHighlights()
//    }
//    private func updateHighlights() {
//        
//        // DONT FORGET TO COMBINE HIGHLIGHTS IF THEY'RE TOUCHING, OR REMOVE IF EMPTY
//        
//        
//        // Define the base attributes to match the text view's styling.
//        let baseAttributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 18),
//            .foregroundColor: UIColor.label
//        ]
//        
//        let mutableAttrString = NSMutableAttributedString(string: text, attributes: baseAttributes)
//        
//        // Apply the orange color highlights
//        print("---- ORANGES ----")
//        for index in (0..<oranges.count).reversed() { // .reversed in case we need to remove an item
//            print("orange[\(index)] has location{\(oranges[index].location)} and length{\(oranges[index].length)}")
//            if oranges[index].location + oranges[index].length > text.count {
//                oranges.remove(at: index)
//            } else {
//                mutableAttrString.addAttribute(.backgroundColor, value: UIColor.systemOrange, range: oranges[index])
//            }
//        }
//        
//        // Apply the blue color highlights
//        print("---- BLUES ----")
//        for index in (0..<blues.count).reversed() { // .reversed in case we need to remove an item
//            print("blue[\(index)] has location{\(blues[index].location)} and length{\(blues[index].length)}")
//            if blues[index].location + blues[index].length > text.count {
//                blues.remove(at: index)
//            } else {
//                mutableAttrString.addAttribute(.backgroundColor, value: UIColor.systemBlue, range: blues[index])
//            }
//        }
//        print("\n\n")
//        
//        // Update the binding that our custom editor uses.
//        attributedText = mutableAttrString // ?? inefficient, should just bodify attributedText directly
//    }
//    //updates state variable
//    func isCursorInBlue() {
//        var i = -1
//        for index in 0..<blues.count {
//            if (selectedRange.location >= blues[index].lowerBound) && (selectedRange.location <= blues[index].upperBound) {
//                i = index
//            }
//        }
//        //        print("cursor in blue[\(i)]")
//        cursorInBlue = i
//    }
//    //updates state variable
//    func isCursorInOrange() {
//        var i = -1
//        for index in 0..<oranges.count {
//            if (selectedRange.location >= oranges[index].lowerBound) && (selectedRange.location <= oranges[index].upperBound) {
//                i = index
//            }
//        }
//        //        print("cursor in orange[\(i)]")
//        cursorInOrange = i
//    }
//    func removeBlue (at index: Int) {
//        blues.remove(at: index)
//        updateHighlights()
//    }
//    func removeOrange(at index: Int) {
//        oranges.remove(at: index)
//        updateHighlights()
//    }
//    func trimText(
//        originalText: String,
//        originalBlues: [NSRange],
//        originalOranges: [NSRange]
//    ) -> (trimmedText: String, trimmedBlues: [NSRange], trimmedOranges: [NSRange]) {
//        
//        // 1) Split the text by newlines
//        let lines = originalText.components(separatedBy: "\n")
//        
//        // We'll gather metadata about each line: how many characters we trimmed
//        // at the start and end, and the old/new coordinate ranges.
//        struct LineInfo {
//            let oldRange: NSRange       // Where the line was in the original text
//            let leadingTrimCount: Int
//            let trailingTrimCount: Int
//            let newRange: NSRange       // Where the line goes in the new text
//        }
//        
//        var lineInfos: [LineInfo] = []
//        var newText = ""
//        
//        // We’ll need a running index to determine each line’s location in the original text.
//        var runningOldLocation = 0
//        
//        // Utility closures for counting spaces
//        func leadingSpacesCount(in s: String) -> Int {
//            var count = 0
//            for c in s {
//                if c == " " || c == "\t" {
//                    count += 1
//                } else {
//                    break
//                }
//            }
//            return count
//        }
//        func trailingSpacesCount(in s: String) -> Int {
//            var count = 0
//            for c in s.reversed() {
//                if c == " " || c == "\t" {
//                    count += 1
//                } else {
//                    break
//                }
//            }
//            return count
//        }
//        
//        // 2) Build the new text line by line, gathering lineInfos.
//        for (i, line) in lines.enumerated() {
//            let lineCount = line.count
//            let oldRange = NSRange(location: runningOldLocation, length: lineCount)
//            
//            let leading = leadingSpacesCount(in: line)
//            let trailing = trailingSpacesCount(in: line)
//            
//            // The trimmed line with leading/trailing spaces removed:
//            let startIndex = line.index(line.startIndex, offsetBy: leading)
//            let endIndex   = line.index(line.endIndex, offsetBy: -trailing)
//            let trimmedLine = (leading + trailing >= lineCount)
//            ? "" // in case line is all whitespace
//            : String(line[startIndex..<endIndex])
//            
//            // The range of this trimmed piece in the *new* text
//            let newLineStart = newText.count
//            let newLineLength = trimmedLine.count
//            
//            // Add the trimmed line to the new text
//            newText.append(trimmedLine)
//            
//            // If not the last line, append the newline that originally separated the lines
//            if i < lines.endIndex - 1 {
//                newText.append("\n")
//            }
//            
//            // Record the mapping
//            let lineInfo = LineInfo(
//                oldRange: oldRange,
//                leadingTrimCount: leading,
//                trailingTrimCount: trailing,
//                newRange: NSRange(location: newLineStart, length: newLineLength)
//            )
//            lineInfos.append(lineInfo)
//            
//            // Advance runningOldLocation by the line length + 1 for the newline
//            runningOldLocation += lineCount + 1
//        }
//        
//        // 3) Mapping function: Given an original NSRange, find the corresponding
//        //    ranges in the new, trimmed text. A single highlight can become multiple
//        //    if it crosses line boundaries.
//        
//        func mapRange(_ range: NSRange) -> [NSRange] {
//            var results: [NSRange] = []
//            
//            for info in lineInfos {
//                // Intersection with the entire (untrimmed) line
//                let intersection = intersectionOfRanges(range1: range, range2: info.oldRange)
//                guard intersection.length > 0 else { continue }
//                
//                // Now clamp out the leading/trailing spaces that were trimmed
//                let lineMin = info.oldRange.location + info.leadingTrimCount
//                let lineMax = info.oldRange.location + info.oldRange.length - info.trailingTrimCount
//                
//                // If highlight is entirely within the trimmed-away portion, skip
//                let clippedStart = max(intersection.location, lineMin)
//                let clippedEnd   = min(intersection.location + intersection.length, lineMax)
//                let clippedLen   = clippedEnd - clippedStart
//                if clippedLen <= 0 { continue }
//                
//                // The highlight portion that remains after trimming
//                // maps into the new text with an offset from lineMin -> info.newRange.location
//                let offset = info.newRange.location - lineMin
//                let newLocation = clippedStart + offset
//                let newRange = NSRange(location: newLocation, length: clippedLen)
//                results.append(newRange)
//            }
//            
//            return results
//        }
//        
//        // 4) Generate the new arrays of highlight ranges
//        let trimmedBlues = originalBlues.flatMap { mapRange($0) }
//        let trimmedOranges = originalOranges.flatMap { mapRange($0) }
//        
//        // 5) Return the new text and new highlight arrays
//        return (newText, trimmedBlues, trimmedOranges)
//    }
//    
//    // A small helper for range intersection in Swift
//    private func intersectionOfRanges(range1: NSRange, range2: NSRange) -> NSRange {
//        let start = max(range1.location, range2.location)
//        let end   = min(range1.location + range1.length, range2.location + range2.length)
//        let length = end - start
//        if length <= 0 {
//            return NSRange(location: 0, length: 0) // Empty
//        }
//        return NSRange(location: start, length: length)
//    }
//    
//    func extractSection(from text: String, with nsRange: NSRange) -> String? {
//        guard let range = Range(nsRange, in: text) else {
//            // The NSRange does not correspond to a valid range in the string.
//            return nil
//        }
//        return String(text[range])
//    }
//    
//    public func addItemsToList() {
//        var items: [OTDItem] = []
//                
//        self.blues.sort { $0.location < $1.location }
//        self.oranges.sort { $0.location < $1.location }
//        
//        var b = 0
//        var o = 0
//        
//        var newItem = OTDItem(header: nil, body: nil, imageReference: nil)
//        
//        for _ in 0..<(blues.count + oranges.count) {
//            var nextRange: NSRange
//            var nextColor: String
//            
//            if b >= blues.count && o < oranges.count  {
//                nextRange = oranges[o]
//                nextColor = "orange"
//                o += 1
//                print("ORANGE NEXT")
//            } else if o >= oranges.count && b < blues.count {
//                nextRange = blues[b]
//                nextColor = "blue"
//                b += 1
//                print("BLUE NEXT")
//            }
//            else if blues[b].location < oranges[o].location {
//                nextRange = blues[b]
//                nextColor = "blue"
//                b += 1
//                print("BLUE NEXT")
//            } else {
//                nextRange = oranges[o]
//                nextColor = "orange"
//                print("ORANGE NEXT")
//                o += 1
//            }
//            
//            let substr = extractSection(from: text, with: nextRange)
//            print("substr: \(substr ?? "failed")")
//            
//            
//            if (nextColor == "blue") {
//                if (newItem.body != nil) {
//                    items.append(newItem)
//                    print("appending item")
//                    newItem = OTDItem(header: nil, body: nil, imageReference: nil)
//                }
//                newItem.body = substr
//                print("filling body blue")
//                
//            } else if (nextColor == "orange") {
//                if (newItem.header != nil) {
//                    items.append(newItem)
//                    newItem = OTDItem(header: nil, body: nil, imageReference: nil)
//                    print("appending item")
//                }
//                newItem.header = substr
//                print("filling header orange")
//            }
//                    
//            
//        }
//        
//        
////        for _ in 0..<(blues.count + oranges.count) {
////            if (blues[b].location < oranges[o].location && b < blues.count) {
////                if (newItem.body == nil ) {
////                    let section: String = extractSection(from: text, with: blues[b]) ?? "nil"
////                    newItem.body = section
////                    print("added body: \(section)")
////                    b += 1
////                } else if (!(blues[b].location > oranges[o].location && o < oranges.count)) {
////                    items.append(newItem)
////                    newItem = OTDItem(header: nil, body: nil, imageReference: nil)
////                    print("added item")
////                }
////            }
////            if (blues[b].location > oranges[o].location && o < oranges.count){
////                if (newItem.header == nil ) {
////                    let section: String = extractSection(from: text, with: oranges[o]) ?? "nil"
////                    newItem.header = section
////                    print("added header: \(section)")
////                    o += 1
////                } else if (!(blues[b].location < oranges[o].location && o < blues.count)) {
////                    items.append(newItem)
////                    newItem = OTDItem(header: nil, body: nil, imageReference: nil)
////                    print("added item")
////                }
////            }
////        }
//        
//        if (newItem.header != nil || newItem.body != nil) {
//            items.append(newItem)
//        }
//        
//        for item in items {
//            viewModel.addItem(item: item)
//        }
//    }
//    
//}
//
//
//
//
//
//
//// MARK: - CustomTextEditor with Attributed Text Support
//
//struct CustomTextEditor: UIViewRepresentable {
//    @Binding var text: String
//    @Binding var attributedText: NSAttributedString?
//    @Binding var selectedRange: NSRange
//    var placeholder: String
//    
//    class Coordinator: NSObject, UITextViewDelegate {
//        var parent: CustomTextEditor
//        
//        init(parent: CustomTextEditor) {
//            self.parent = parent
//        }
//        
//        func textViewDidChange(_ textView: UITextView) {
//            // Update the plain text binding from the UITextView.
//            parent.text = textView.text
//            // Reset attributed text once the user edits.
//            parent.attributedText = nil
//        }
//        
//        func textViewDidChangeSelection(_ textView: UITextView) {
//            let maxLength = textView.text.count
//            if textView.selectedRange.location != NSNotFound,
//               textView.selectedRange.location >= 0,
//               textView.selectedRange.location <= maxLength {
//                parent.selectedRange = textView.selectedRange
//            }
//        }
//        
//        func textViewDidBeginEditing(_ textView: UITextView) {
//            // Remove placeholder when editing begins.
//            if textView.text == parent.placeholder {
//                textView.text = ""
//                textView.textColor = UIColor.label
//            }
//        }
//        
//        func textViewDidEndEditing(_ textView: UITextView) {
//            // Restore placeholder if text is empty.
//            if textView.text.isEmpty {
//                textView.text = parent.placeholder
//                textView.textColor = UIColor.lightGray
//            }
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(parent: self)
//    }
//    
//    func makeUIView(context: Context) -> UITextView {
//        let textView = UITextView()
//        textView.delegate = context.coordinator
//        textView.isScrollEnabled = true
//        textView.isEditable = true
//        textView.isUserInteractionEnabled = true
//        textView.backgroundColor = UIColor.secondarySystemBackground
//        textView.font = UIFont.systemFont(ofSize: 18)
//        
//        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        textView.layer.cornerRadius = 10
//        
//        if let attrText = attributedText {
//            // If an attributed text exists, display it.
//            textView.attributedText = attrText
//        } else {
//            // Otherwise, use plain text (or placeholder if empty).
//            textView.text = text.isEmpty ? placeholder : text
//            textView.textColor = text.isEmpty ? UIColor.lightGray : UIColor.label
//        }
//        
//        return textView
//    }
//    
//    func updateUIView(_ textView: UITextView, context: Context) {
//        if let attrText = attributedText {
//            // If an attributed text is set, update the UITextView.
//            textView.attributedText = attrText
//            // Also update the plain text binding.
//            DispatchQueue.main.async {
//                self.text = attrText.string
//            }
//        } else {
//            // Use plain text as usual.
//            if text.isEmpty && !textView.isFirstResponder {
//                textView.text = placeholder
//                textView.textColor = UIColor.lightGray
//            } else if textView.text != text {
//                textView.text = text
//                textView.textColor = UIColor.label
//            }
//        }
//        
//        // Ensure the selection range remains valid.
//        let maxLength = textView.text.count
//        if selectedRange.location != NSNotFound,
//           selectedRange.location >= 0,
//           selectedRange.location + selectedRange.length <= maxLength {
//            textView.selectedRange = selectedRange
//        } else {
//            textView.selectedRange = NSRange(location: 0, length: 0)
//        }
//    }
//}
//
//
//
//
//
//
//
//// ITEM PARSER GAAAAAAAHH
//class ItemParser {
//    
//    enum Category: String {
//        case letter, digit, whitespace, punctuation, symbol, newline, other
//    }
//    
//    private static let catMap: [Character: Category] = {
//        var map = [Character: Category]()
//        
//        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
////        let digits = "0123456789"
//        let whitespace = " \t\r"
//        let punctuation = "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~"
//        let symbols = "€£¥©®™§¶±÷×°"
//        let newline = "\n"
//        
//        for char in letters { map[char] = .letter }
////        for char in digits { map[char] = .digit }
//        for char in whitespace { map[char] = .whitespace }
//        for char in punctuation { map[char] = .punctuation }
//        for char in symbols { map[char] = .symbol }
//        for char in newline { map[char] = .newline }
//        
//        return map
//    }()
//    
//    private static func catOf(_ char: Character) -> Category {
//        return catMap[char] ?? .other
//    }
//    
//    
//    private class Delimiter {
//        public var separationText: String
//        public var catOrder: [Category]
//        
//        private var i: Int
//        
//        init(separationText: String) {
//            self.separationText = separationText
//            self.catOrder = []
//            self.i = 0
//            
//            generateCatOrder()  
//        }
//        
//        private func generateCatOrder () {
//            var catIndex = -1
//            var currCat: Category = .other
//            var isFirstCat = true
//            for char in self.separationText {
//                let charCat = catOf(char)
//                if charCat != currCat {
//                    currCat = charCat
//                    
//                    // Account for exceptions/rules
//                    if !isFirstCat {
//                        let lastCat = catOrder[catIndex]
//                        
//                        // If the last category is letter, skip whitespace or punctuation.
//                        if lastCat == .letter && (currCat == .whitespace || currCat == .punctuation) {
//                            currCat = .letter
//                            continue
//                        }
//                        // New rule: If the last category is punctuation, skip whitespace.
//                        else if lastCat == .punctuation && currCat == .whitespace {
//                            currCat = .punctuation
//                            continue
//                        }
//                        else {
//                            catOrder.append(currCat)
//                            catIndex += 1
//                        }
//                    } else {
//                        catOrder.append(currCat)
//                        catIndex += 1
//                        isFirstCat = false
//                    }
//                }
//            }
//        }
//        
//        public func printDel() {
//            print("Delimiters: ")
//            for c in catOrder {
//                print("\(c)")
//            }
//            print("-----------------------------")
//        }
//    }
//    
//    enum hType {
//        case orange // orange
//        case blue // blue
//    }
//    
//    public var text: String
//    private var pos: Int // where we are in the text
//    
//    // both will be in order of location when initialized
//    public var blues: [NSRange]
//    public var oranges: [NSRange]
//    
//    private var delimeters: [Delimiter]
//    private var orderedHighlights: [(NSRange, hType)]
//    
//    init(text: String, blues: [NSRange], oranges: [NSRange]) {
//        self.text = text
//        self.pos = 0
//        
//        self.blues = blues
//        self.oranges = oranges
//        
//        self.orderedHighlights = []
//        self.delimeters = []
//        
//        // calculate real values for items
//        self.orderedHighlights = sortHighlights()
//        self.delimeters = makeDelimiters()
//    }
//    
//    // sorts blues and oranges in place and creates a combined order
//    private func sortHighlights() -> [(NSRange, hType)] {
//        // Sort both arrays separately
//        self.blues.sort { $0.location < $1.location }
//        self.oranges.sort { $0.location < $1.location }
//        
//        // Combine both arrays with their corresponding type
//        var combined = blues.map { ($0, hType.blue) } + oranges.map { ($0, hType.orange) }
//        
//        // Sort the combined array based on NSRange location
//        combined.sort { $0.0.location < $1.0.location }
//        
//        return combined
//    }
//    
//    public func rebuildBluesAndOranges() {
//        // First, clear out the existing arrays
//        self.blues.removeAll()
//        self.oranges.removeAll()
//        
//        // Loop through the combined highlights
//        for (range, type) in orderedHighlights {
//            switch type {
//            case .blue:
//                self.blues.append(range)
//            case .orange:
//                self.oranges.append(range)
//            }
//        }
//        
//        // (Optionally) re-sort them by location
//        self.blues.sort { $0.location < $1.location }
//        self.oranges.sort { $0.location < $1.location }
//    }
//    
//    private func makeDelimiters() -> [Delimiter] {
//        var newDelims: [Delimiter] = []
//        for i in 0..<(orderedHighlights.count - 1) {
//            let (rangeA, _) = orderedHighlights[i]
//            let (rangeB, _) = orderedHighlights[i+1]
//            
//            // The text between these two highlights:
//            let startLocation = rangeA.location + rangeA.length
//            let endLocation   = rangeB.location
//            
//            guard startLocation < text.count, endLocation <= text.count else {
//                continue
//            }
//            // Convert to string indices
//            let startIndex = text.index(text.startIndex, offsetBy: startLocation)
//            let endIndex   = text.index(text.startIndex, offsetBy: endLocation)
//            
//            let separationStr = String(text[startIndex..<endIndex])
//            let delim = Delimiter(separationText: separationStr)
//            newDelims.append(delim)
//        }
//        // make the wrap-around delimiter
//        // get the first occurance of that type-transition
//        // duplicate it as the last delimiter
//        // Determine the desired wrap-around transition: from the last highlight type to the first highlight type.
//        guard let firstHighlight = orderedHighlights.first, let lastHighlight = orderedHighlights.last else {
//            return newDelims
//        }
//        let requiredTransition: (hType, hType) = (lastHighlight.1, firstHighlight.1)
//        
//        // Find the first occurrence of that transition among the existing consecutive pairs.
//        var wrapDelimiter: Delimiter?
//        for i in 0..<(orderedHighlights.count - 1) {
//            let currentTransition: (hType, hType) = (orderedHighlights[i].1, orderedHighlights[i+1].1)
//            if currentTransition == requiredTransition {
//                wrapDelimiter = newDelims[i] // The delimiter between highlights[i] and highlights[i+1]
//                break
//            }
//        }
//        
//        // If no occurrence is found, default to the first delimiter if available, else use an empty delimiter.
//        if let wrapDelim = wrapDelimiter {
//            newDelims.append(Delimiter(separationText: wrapDelim.separationText))
//        } else if let firstDelimiter = newDelims.first {
//            print("WRAP DELIM FAILED, this scenario should be avoided by the UI with a parsable boolean")
//            newDelims.append(Delimiter(separationText: firstDelimiter.separationText))
//        } else {
//            print("WRAP DELIM FAILED, this scenario should be avoided by the UI with a parsable boolean")
//            newDelims.append(Delimiter(separationText: ""))
//        }
//        
//        
//        
////        print("made \(newDelims.count) delimiters")
////        for d in newDelims {
////            d.printDel()
////        }
//        return newDelims
//    }
//    
//    private func findDelimiterMatch(startingAt searchPos: Int,
//                                      delim: Delimiter) -> (Int, Int)? {
//        let pattern = delim.catOrder
//        if pattern.isEmpty {
//            return (searchPos, searchPos)
//        }
//        
//        let textCount = text.count
//        var candidateStart = searchPos
//        
//        while candidateStart < textCount {
//            var catIndex = 0
//            var pos = candidateStart
//            
////            print("Trying candidate start at index \(candidateStart)...")
//            
//            // Process each expected category in the delimiter pattern
//            while catIndex < pattern.count && pos < textCount {
//                let neededCat = pattern[catIndex]
//                
//                // Pre-match skip: skip exception characters
//                while pos < textCount && pos > candidateStart {
//                    let currIndex = text.index(text.startIndex, offsetBy: pos)
//                    let currentChar = text[currIndex]
//                    let currentCat = ItemParser.catOf(currentChar)
//                    
//                    let prevIndex = text.index(text.startIndex, offsetBy: pos - 1)
//                    let prevChar = text[prevIndex]
//                    let prevCat = ItemParser.catOf(prevChar)
//                    
//                    // If previous is letter, skip both whitespace and punctuation.
//                    if prevCat == .letter && (currentCat == .whitespace || currentCat == .punctuation) {
////                        print("Skipping exception character '\(currentChar)' at pos \(pos) (whitespace/punctuation after letter)")
//                        pos += 1
//                        continue
//                    }
//                    // If previous is punctuation, skip whitespace.
//                    else if prevCat == .punctuation && currentCat == .whitespace {
////                        print("Skipping exception character '\(currentChar)' at pos \(pos) (whitespace after punctuation)")
//                        pos += 1
//                        continue
//                    }
//                    break
//                }
//                
//                // If we've run out of characters, break out.
//                if pos >= textCount { break }
//                
//                let currIndex = text.index(text.startIndex, offsetBy: pos)
//                let currentChar = text[currIndex]
//                let currentCat = ItemParser.catOf(currentChar)
//                
//                if currentCat != neededCat {
////                    print("Mismatch at pos \(pos): found '\(currentChar)' (\(currentCat)) but expected \(neededCat)")
//                    break
//                }
//                
////                print("Matched expected character '\(currentChar)' at pos \(pos) with category \(neededCat)")
//                pos += 1
//                
//                // Consume the entire run of characters matching neededCat.
//                var lastValidCat = currentCat
//                while pos < textCount {
//                    let runIndex = text.index(text.startIndex, offsetBy: pos)
//                    let runChar = text[runIndex]
//                    let runCat = ItemParser.catOf(runChar)
//                    
//                    if runCat == neededCat {
////                        print("Consuming '\(runChar)' at pos \(pos) as part of run for \(neededCat)")
//                        lastValidCat = runCat
//                        pos += 1
//                    }
//                    // Exception: if the run's last valid char was letter, skip whitespace or punctuation.
//                    else if lastValidCat == .letter && (runCat == .whitespace || runCat == .punctuation) {
////                        print("Skipping exception character '\(runChar)' at pos \(pos) after letter in run")
//                        pos += 1
//                    }
//                    // Exception: if the last valid char was punctuation, skip whitespace.
//                    else if lastValidCat == .punctuation && runCat == .whitespace {
////                        print("Skipping exception character '\(runChar)' at pos \(pos) after punctuation in run")
//                        pos += 1
//                    }
//                    else {
//                        break
//                    }
//                }
//                
//                catIndex += 1
//            }
//            
//            // New handling: if we reached the end of the text before consuming all expected categories,
//            // but the remaining expected categories are only whitespace and newline, treat it as a match.
//            if pos >= textCount && catIndex < pattern.count {
//                var allOptional = true
//                for i in catIndex..<pattern.count {
//                    let cat = pattern[i]
//                    if cat != .whitespace && cat != .newline {
//                        allOptional = false
//                        break
//                    }
//                }
//                if allOptional {
////                    print("Reached end-of-text; remaining expected categories are optional. " + "Delimiter match accepted from index \(candidateStart) to \(pos)")
//                    return (candidateStart, pos)
//                }
//            }
//            
//            if catIndex == pattern.count {
////                print("Delimiter match found from index \(candidateStart) to \(pos)")
//                return (candidateStart, pos)
//            }
//            
//            candidateStart += 1
//        }
//        
////        print("No delimiter match found.")
//        return nil
//    }
//    
//    public func makeHighlights() {
//        guard !orderedHighlights.isEmpty else { return }
//        guard !delimeters.isEmpty else {
//            // If there are no delimiters (meaning only one highlight range was given),
//            // then we could highlight everything with that single highlight type:
//            let ht = (orderedHighlights.first?.1) ?? .blue
//            let leftoverLen = text.count - pos
//            if leftoverLen > 0 {
//                let leftoverRange = NSRange(location: pos, length: leftoverLen)
//                orderedHighlights.append((leftoverRange, ht))
//            }
//            return
//        }
//        
//        var newHighlights: [(NSRange, hType)] = []
//        
//        // We’ll cycle over highlight types with hIndex, and delimiter patterns with dIndex.
//        var hIndex = 0
//        var dIndex = 0
//        
//        while pos < text.count {
//            // The highlight we’re about to emit
//            let highlightType = orderedHighlights[hIndex].1
//            
//            // Attempt to find the next delimiter
//            let delimiter = delimeters[dIndex]
//            if let (delimStart, delimEnd) = findDelimiterMatch(startingAt: pos, delim: delimiter) {
//                // So the highlight goes from pos ..< delimStart
//                if delimStart > pos {
//                    let highlightLen = delimStart - pos
//                    let highlightRange = NSRange(location: pos, length: highlightLen)
//                    newHighlights.append((highlightRange, highlightType))
////                    print("added highlight of type \(highlightType)")
//
//                }
//                // Now skip the delimiter’s match
//                pos = delimEnd
//            } else {
//                // If we didn’t find the delimiter, the rest of the text is highlight
//                let highlightLen = text.count - pos
//                let highlightRange = NSRange(location: pos, length: highlightLen)
//                newHighlights.append((highlightRange, highlightType))
////                print("added highlight of type \(highlightType)")
//                pos = text.count
//            }
//            
//            // Move forward in highlight & delimiter arrays, wrapping around
//            hIndex = (hIndex + 1) % orderedHighlights.count
//            dIndex = (dIndex + 1) % delimeters.count
//        }
//        
//        // Add newly formed highlights to `orderedHighlights`.
//        orderedHighlights = newHighlights
//        // Re-sort by location, in case you want them in ascending index order:
//        orderedHighlights.sort { $0.0.location < $1.0.location }
//        
//        rebuildBluesAndOranges()
//    }
//}
