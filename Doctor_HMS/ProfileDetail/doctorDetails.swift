//
//  doctorDetails.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 30/04/24.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct Profile_Create: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: DoctorViewModel
    @State private var navigationLinkIsActive = false
    let email:String
    let password:String
    @State private var isImagePickerP = false
    @State private var isImagePickerPresented = false
    @State private var posterImage : UIImage?
    @State private var defaultposterImage : UIImage = UIImage(named: "default_hackathon_poster")!
    let genders = ["Male", "Female", "Other"]
  

    @State private var healthRecordPDFs: [Data] = [] // Array to store PDF data
        @State private var selectedPDFName: String? = nil // Store selected PDF name
        

    var body: some View {
        VStack {
            
            
            Form{
                VStack{
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
                                Circle()
                                    .fill(Color.solitude)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Image(systemName: "camera.fill")
                                            .resizable()
                                            .frame(width: 50, height: 40)
                                            .foregroundStyle(Color.gray)
                                    )
                            }
                        }
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImageP(posterImage: $posterImage, defaultPoster: defaultposterImage)
                        }
                        Spacer()
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .background(Color.solitude)
                }
                .padding()
                VStack{
                    
                        
                    HStack {
                        TextField("Full Name", text: $profileViewModel.currentProfile.fullName)
                            .keyboardType(.numberPad)
                            .underlineTextField()
                            
                    }
                    .padding(.bottom, 15.0)
                    HStack {
                        TextField("Enter Mobile Number", text: $profileViewModel.currentProfile.mobileno)
                            .keyboardType(.numberPad)
                            .underlineTextField()
                            
                    }
                    .padding(.bottom, 15.0)
                    
                    VStack{
                        
                        TextField("your experience details" , text: $profileViewModel.currentProfile.experience)
                            .padding(.bottom, 15.0)
                        TextField("your qualification Details" , text: $profileViewModel.currentProfile.qualification)
                            .padding(.bottom, 15.0)
                        TextField("Your description" , text: $profileViewModel.currentProfile.descript)
                            .padding(.bottom, 15.0)
                        
                        TextField("Your Department" , text: $profileViewModel.currentProfile.department)
                            .padding(.bottom, 15.0)
                        
                        TextField("Your Speciality" , text: $profileViewModel.currentProfile.speciality)
                            .padding(.bottom, 15.0)
                        TextField("Your Cabin Number" , text: $profileViewModel.currentProfile.cabinNo)
                            .padding(.bottom, 15.0)
                        
                    }
                  
                    
                    HStack {
                        DatePicker("Date of Birth", selection: $profileViewModel.currentProfile.dob,
                                   in: ...Date(),
                                   displayedComponents: [.date])
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
                        TextField("Your Address", text: $profileViewModel.currentProfile.address)
                            .underlineTextField()
                    }
                    .padding(.bottom, 15.0)

                    
                    HStack {
                        TextField("Enter Pincode", text: $profileViewModel.currentProfile.pincode)
                            .keyboardType(.numberPad)
                            .underlineTextField()
                    }
                    .padding(.bottom, 15.0)
                    
                  
                    
              
                    
                }
                HStack{
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.createUser(withEmail: email, password: password)
                                profileViewModel.updateProfile(profileViewModel.currentProfile, posterImage: posterImage ?? defaultposterImage, userId: viewModel.currentUser?.id) {
                                }
                                
                                try await profileViewModel.AddDepartment(
                                    department: profileViewModel.currentProfile.department,
                                    speciality: profileViewModel.currentProfile.speciality,
                                    cabinNo: profileViewModel.currentProfile.cabinNo)
                                
                            } catch {
                                
                                print("Error: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Get Started")
                            .foregroundColor(.buttonForeground)
                            .frame(width: 300, height: 30)
                            .padding()
                            .background(Color.midNightExpress)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Create Your Profile")
        }
        .padding(10)
    }
}

struct Profile_Create_Previews: PreviewProvider {
    static var previews: some View {
        Profile_Create(email: "", password: "")
            .environmentObject(AuthViewModel())
            .environmentObject(DoctorViewModel())
    }
}
