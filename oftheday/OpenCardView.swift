import SwiftUI

struct OpenCardView: View {
    // Binding to show/dismiss this view
    @Binding var isPresented: Bool
    let item: OTDItem
    let imageRef: String?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Image Logic
                if let imageRef = item.imageReference, let uiImage = ImageTable.imageTable.getImage(byID: imageRef) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .clipped()
                        
                } else if let imageRef = imageRef, let uiImage = ImageTable.imageTable.getImage(byID: imageRef) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geometry.size.width, height: geometry.size.height)
//                        .clipped()
                } else {
                    Color(UIColor.systemBackground)
                        .ignoresSafeArea()
                }
                
                // Overlaying a semi-transparent background to improve text visibility
//                Color.black.opacity(0.3)
//                    .edgesIgnoringSafeArea(.all)
//                
                ScrollView {
                    VStack(alignment: .center, spacing: 20) {
                        // Full Title
                        Text(item.header ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                            .padding(.top, 20)
                        
                        // Full Body
                        Text(item.body ?? "")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                            .padding(.horizontal, 16)
                    }
                    .frame(width: geometry.size.width * 0.9)
                    .frame(minHeight: geometry.size.height)
                    .padding(.horizontal, 16)
                }
            }
        }
        .onTapGesture {
            // Close fullscreen view by tapping anywhere
            isPresented = false
        }
    }
}
