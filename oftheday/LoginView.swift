//
//  LoginPage.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/19/25.
//

import SwiftUI


struct LoginView: View {
    @EnvironmentObject var userModel: OTDUserModel
    @Binding var showLogin: Bool
    
    @State private var name: String = ""
    @State private var profilePic: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Register")
                    .font(.largeTitle)
                    .padding(.bottom, 40)
                
                TextField("Enter your name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    if let image = profilePic {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        // Display a default circle with the first initial.
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 100, height: 100)
                            Text(String(name.prefix(1)).uppercased())
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .sheet(isPresented: $isImagePickerPresented) {
//                    ImagePicker(image: $profilePic)
                    Text("no image picker for setting profile pic, update this eventually")
                }
                
                Button(action: registerUser) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
        }
    }
    
    func registerUser() {
        guard !name.isEmpty else { return }
        // Create a new user; here, "custom" is used as a placeholder for a chosen image.
        let newUser = OTDUser(name: name, profilePic: profilePic != nil ? "custom" : nil, lists: [])
        userModel.saveUser(newUser)
        userModel.loadDefaults()
        showLogin = false
    }
}
