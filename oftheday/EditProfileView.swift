//
//  EditProfileView.swift
//  oftheday
//
//  Created by Kai Sorensen on 2/19/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var userModel: OTDUserModel
    @State private var name: String = ""
    @State private var profilePic: UIImage? = nil
    @State private var isImagePickerPresented: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Edit Profile")
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
//                    ImagePicker
                    Text("no images picker for profile right now")
//                    (image: $profilePic)
                }
                
                Button(action: updateProfile) {
                    Text("Save Changes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
            }
            .onAppear {
                if let currentUser = userModel.currentUser {
                    self.name = currentUser.name
                    // For simplicity, this example does not retrieve an actual image.
                }
            }
        }
    }
    
    func updateProfile() {
        guard !name.isEmpty, var user = userModel.currentUser else { return }
        user.name = name
        user.profilePic = profilePic != nil ? "custom" : nil
        userModel.saveUser(user)
        presentationMode.wrappedValue.dismiss()
    }
}
