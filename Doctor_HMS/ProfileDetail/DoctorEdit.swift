//
//  DoctorEdit.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 30/04/24.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers
struct Profile_Edit: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: DoctorViewModel
    @State private var navigationLinkIsActive = false
    @State private var isImagePickerP = false
    @State private var isImagePickerPresented = false
    @State private var posterImage : UIImage?
    @State private var defaultposterImage : UIImage = UIImage(named: "default_hackathon_poster")!
  
    let genders = ["Male", "Female", "Other"]
   
//    @State private var healthRecordPDFs: [Data] = [] // Array to store PDF data
        @State private var selectedPDFName: String? = nil // Store selected PDF name
        

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Edit Profile")) {
                    // CameraButton
                    HStack {
                        Spacer()
                        Button(action: {
                                                        isImagePickerPresented.toggle()
                                                    }) {
                                                        if let posterImage = posterImage {
                                                            Image(uiImage: posterImage)
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 100, height: 100)
                                                                .cornerRadius(10)
                                                        } else {
                                                            if let posterURL = profileViewModel.currentProfile.profilephoto {
                                                                AsyncImage(url: URL(string: posterURL)) { phase in
                                                                    switch phase {
                                                                    case .success(let image):
                                                                        image
                                                                            .resizable()
                                                                            .aspectRatio(contentMode: .fill)
                                                                            .frame(width: 350, height: 200)
                                                                            .cornerRadius(20.0)
                                                                            .clipShape(Circle())
                                                                            .padding([.leading, .bottom, .trailing])
                                                                    default:
                                                                        ProgressView()
                                                                            .frame(width: 50, height: 50)
                                                                            .padding([.leading, .bottom, .trailing])
                                                                    }
                                                                }
                                                            } else {
                                                                Image(uiImage: UIImage(named: "default_hackathon_poster")!)
                                                                    .resizable()
                                                                    .aspectRatio(contentMode: .fill)
                                                                    .frame(width: 350, height: 200)
                                                                    .cornerRadius(20.0)
                                                                    .clipShape(Circle())
                                                                    .padding([.leading, .bottom, .trailing])
                                                            }
                                                        }
                                                    }
                                                    .sheet(isPresented: $isImagePickerPresented) {
                                                        ImageP(posterImage: $posterImage, defaultPoster: defaultposterImage)
                                                    }
                        Spacer()
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    HStack {
                        Text("Full Name: ")
                        TextField("Name", text: $profileViewModel.currentProfile.fullName)
                    }
                    .padding(.bottom, 15.0)
                    
                    
                    HStack {
                        Text("Qualification :")
                        TextField("Qualification", text: $profileViewModel.currentProfile.qualification)
                            .padding()
                        Text("Experience")
                        TextField("Experience" , text: $profileViewModel.currentProfile.experience)
                            .padding()
                        Text("description")
                        TextField("description" , text: $profileViewModel.currentProfile.descript)
                    }
                    
                  
                    
                    HStack {
                                Text("Mobile Number: ")
                                TextField("Enter Mobile Number", text: $profileViewModel.currentProfile.mobileno)
                                    .keyboardType(.numberPad)
                            }
                    .padding(.bottom, 15.0)
                    
                    HStack {
                                Text("qualification: ")
                                TextField("Enter Mobile Number", text: $profileViewModel.currentProfile.qualification)
                                    .keyboardType(.numberPad)
                            }
                    
                    .padding(.bottom, 15.0)
                    
                    HStack{
                        Picker("Select Gender", selection: $profileViewModel.currentProfile.gender) {
                            ForEach(genders, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }.padding(.bottom, 15.0)
                  
                
                    
                    HStack {
                        DatePicker("Date of Birth", selection: $profileViewModel.currentProfile.dob,
                                   in: Date()..., displayedComponents: [.date])
                    }
                    .padding(.bottom, 15.0)
                    
                    HStack {
                        Text("Address: ")
                        TextField("Your Address", text: $profileViewModel.currentProfile.address)
                    }
                    .padding(.bottom, 15.0)
                    
                    HStack {
                                Text("Pincode: ")
                        TextField("Enter Pincode", text: $profileViewModel.currentProfile.pincode)
                                    .keyboardType(.numberPad)
                            }
                    .padding(.bottom, 15.0)
                    

                                }
            }
            
            Button(action: {
                Task {
                    
                    profileViewModel.updateProfile(profileViewModel.currentProfile, posterImage: posterImage ?? defaultposterImage, userId: viewModel.currentUser?.id) {
                        }
                    
                    
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Edit Profile")
                    .foregroundColor(.blue)
                    .padding()
            }
           
            
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Create Your Profile")
        .padding(.horizontal, 7)
    }
}

