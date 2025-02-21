import SwiftUI

struct ItemView: View {
    @Binding var item: OTDItem?
    
    // Tracks the expanded (full-screen) state
    @State private var showOpenCard: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            if item != nil {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 4)
                
//                if let imageRef = item.imageReference, let uiImage = ImageTable.imageTable.getImage(byID: imageRef) {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 250) // Ensure it only takes the lower portion of the card
//                        .clipped()
//                } else if let imageRef = imageRef, let uiImage = ImageTable.imageTable.getImage(byID: imageRef) {
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 250) // Ensure it only takes the lower portion of the card
//                        .clipped()
//                } 
                
                VStack {
                    // Title in top-left
                    HStack {
                        Text(item!.header ?? "")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.top, 16)
                            .padding(.leading, 16)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    // Body in the center
                    Text(item!.body ?? "")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 16)
                    
                    Spacer()
                }
                // Open the full-screen card when tapped
                
            } else {
                // If list is empty, just show the placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground))
                
                Text("~ pure potential ~")
                    .multilineTextAlignment(.center)
            }
        }
        // Present the fullscreen view when showOpenCard is true
//        .fullScreenCover(isPresented: $showOpenCard) {
//            OpenCardView(isPresented: $showOpenCard, item: item, imageRef: imageRef)
//        }
//        .onTapGesture {
//            if (!isListEmpty) {showOpenCard = true}
//        }
    }
}
