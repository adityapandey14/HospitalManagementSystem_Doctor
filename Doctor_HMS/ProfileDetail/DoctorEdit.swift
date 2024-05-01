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

    @State private var isImagePickerPresented = false
    @State private var posterImage: UIImage?
    @State private var defaultPosterImage: UIImage = UIImage(named: "default_hackathon_poster")!
  
    let genders = ["Male", "Female", "Other"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Image Picker Button
                HStack {
                    Button(action: {
                        isImagePickerPresented.toggle()
                    }) {
                        if let posterImage = posterImage {
                            Image(uiImage: posterImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        } else if let posterURL = profileViewModel.currentProfile.profilephoto {
                            AsyncImage(url: URL(string: posterURL)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                default:
                                    ProgressView()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                }
                            }
                        } else {
                            Image(uiImage: defaultPosterImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        }
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImageP(posterImage: $posterImage, defaultPoster: defaultPosterImage)
                    }
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.bottom, 20)

                // Form Fields
                Group {
                    LabeledTextField(label: "Full Name", text: $profileViewModel.currentProfile.fullName)
                    LabeledTextField(label: "Experience", text: $profileViewModel.currentProfile.experience)
                    LabeledTextField(label: "Description", text: $profileViewModel.currentProfile.descript)
                    LabeledTextField(label: "Mobile Number", text: $profileViewModel.currentProfile.mobileno, keyboardType: .numberPad)
                    LabeledTextField(label: "Qualification", text: $profileViewModel.currentProfile.qualification)
                    Picker("Select Gender", selection: $profileViewModel.currentProfile.gender) {
                        ForEach(genders, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.top, 10)

                    DatePicker(
                        "Date of Birth",
                        selection: $profileViewModel.currentProfile.dob,
                        displayedComponents: [.date]
                    )
                    .padding(.top, 10)

                    LabeledTextField(label: "Address", text: $profileViewModel.currentProfile.address)
                    LabeledTextField(label: "Pincode", text: $profileViewModel.currentProfile.pincode, keyboardType: .numberPad)
                    LabeledTextField(label: "Department", text: $profileViewModel.currentProfile.department)
                    LabeledTextField(label: "Speciality", text: $profileViewModel.currentProfile.speciality)
                    LabeledTextField(label: "Cabin Number", text: $profileViewModel.currentProfile.cabinNo)
                }
                .padding(.bottom, 10)

                // Edit Profile Button
                Button(action: {
                    Task {
                        profileViewModel.updateProfile(
                            profileViewModel.currentProfile,
                            posterImage: posterImage ?? defaultPosterImage,
                            userId: viewModel.currentUser?.id
                        ) {
                            print("Profile updated successfully")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Edit Profile")
                        .foregroundColor(.white)
                        .frame(width: 325, height: 50)
                        .background(Color.midNightExpress)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Edit Your Profile")
    }
}

struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.headline)
            TextField("Enter \(label)", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .padding(.vertical, 5)
        }
    }
}
