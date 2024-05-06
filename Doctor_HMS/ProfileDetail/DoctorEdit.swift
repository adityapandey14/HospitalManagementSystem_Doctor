////
////  DoctorEdit.swift
////  Doctor_HMS
////
////  Created by Aditya Pandey on 30/04/24.
////
//
//import SwiftUI
//import MobileCoreServices
//import UniformTypeIdentifiers
//
//struct Profile_Edit: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var viewModel: AuthViewModel
//    @EnvironmentObject var profileViewModel: DoctorViewModel
//
//    @State private var isImagePickerPresented = false
//    @State private var posterImage: UIImage?
//    @State private var defaultPosterImage: UIImage = UIImage(named: "default_hackathon_poster")!
//  
//    let genders = ["Male", "Female", "Other"]
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 15) {
//                // Image Picker Button
//                HStack {
//                    Button(action: {
//                        isImagePickerPresented.toggle()
//                    }) {
//                        if let posterImage = posterImage {
//                            Image(uiImage: posterImage)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 100, height: 100)
//                                .clipShape(Circle())
//                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                        } else if let posterURL = profileViewModel.currentProfile.profilephoto {
//                            AsyncImage(url: URL(string: posterURL)) { phase in
//                                switch phase {
//                                case .success(let image):
//                                    image
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                default:
//                                    ProgressView()
//                                        .frame(width: 100, height: 100)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                                }
//                            }
//                        } else {
//                            Image(uiImage: defaultPosterImage)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 100, height: 100)
//                                .clipShape(Circle())
//                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//                        }
//                    }
//                    .sheet(isPresented: $isImagePickerPresented) {
//                        ImageP(posterImage: $posterImage, defaultPoster: defaultPosterImage)
//                    }
//                    Spacer()
//                }
//                .padding(.top, 20)
//                .padding(.bottom, 20)
//
//                // Form Fields
//                Group {
//                    LabeledTextField(label: "Full Name", text: $profileViewModel.currentProfile.fullName)
//                    LabeledTextField(label: "Experience", text: $profileViewModel.currentProfile.experience)
//                    LabeledTextField(label: "Description", text: $profileViewModel.currentProfile.descript)
//                    LabeledTextField(label: "Mobile Number", text: $profileViewModel.currentProfile.mobileno, keyboardType: .numberPad)
//                    LabeledTextField(label: "Qualification", text: $profileViewModel.currentProfile.qualification)
//                    Picker("Select Gender", selection: $profileViewModel.currentProfile.gender) {
//                        ForEach(genders, id: \.self) {
//                            Text($0)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .padding(.top, 10)
//
//                    DatePicker(
//                        "Date of Birth",
//                        selection: $profileViewModel.currentProfile.dob,
//                        displayedComponents: [.date]
//                    )
//                    .padding(.top, 10)
//
//                    LabeledTextField(label: "Address", text: $profileViewModel.currentProfile.address)
//                    LabeledTextField(label: "Pincode", text: $profileViewModel.currentProfile.pincode, keyboardType: .numberPad)
//                    LabeledTextField(label: "Department", text: $profileViewModel.currentProfile.department)
//                    LabeledTextField(label: "Speciality", text: $profileViewModel.currentProfile.speciality)
//                    LabeledTextField(label: "Cabin Number", text: $profileViewModel.currentProfile.cabinNo)
//                }
//                .padding(.bottom, 10)
//
//                // Edit Profile Button
//                Button(action: {
//                    Task {
//                        profileViewModel.updateProfile(
//                            profileViewModel.currentProfile,
//                            posterImage: posterImage ?? defaultPosterImage,
//                            userId: viewModel.currentUser?.id
//                        ) {
//                            print("Profile updated successfully")
//                        }
//                        do {
//                                              // Call the async method with await
//                                              try await profileViewModel.AddDepartment(
//                                                  department: profileViewModel.currentProfile.department,
//                                                  speciality: profileViewModel.currentProfile.speciality,
//                                                  cabinNo: profileViewModel.currentProfile.cabinNo
//                                              )
//                                              print("Department updated successfully")
//                                          } catch {
//                                              print("Error updating department: \(error.localizedDescription)")
//                                          } // End of catch block
//                        
//                    }
//                    presentationMode.wrappedValue.dismiss()
//                }) {
//                    Text("Edit Profile")
//                        .foregroundColor(.white)
//                        .frame(width: 325, height: 50)
//                        .background(Color.midNightExpress)
//                        .cornerRadius(10)
//                }
//            }
//            .padding(.horizontal)
//        }
//        .navigationTitle("Edit Your Profile")
//    }
//}
//
//struct LabeledTextField: View {
//    let label: String
//    @Binding var text: String
//    var keyboardType: UIKeyboardType = .default
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Text(label)
//                .font(.headline)
//            TextField("Enter \(label)", text: $text)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .keyboardType(keyboardType)
//                .padding(.vertical, 5)
//        }
//    }
//}

//-----------------------------------------------
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct Profile_Edit_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Profile_Edit()
                .environmentObject(DoctorViewModel()) // Provide DoctorViewModel
                .environmentObject(AuthViewModel()) // Provide AuthViewModel
        }
    }
}

struct Profile_Edit: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: DoctorViewModel

    @State private var isImagePickerPresented = false
    @State private var posterImage: UIImage?
    @State private var defaultPosterImage: UIImage = UIImage(named: "profilePictureDefault")!

    let genders = ["Male", "Female", "Other"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile Image
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isImagePickerPresented.toggle()
                        }) {
                            if let posterImage = posterImage {
                                Image(uiImage: posterImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            } else if let posterURL = profileViewModel.currentProfile.profilephoto {
                                AsyncImage(url: URL(string: posterURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                    default:
                                        ProgressView()
                                            .frame(width: 120, height: 100)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                    }
                                }
                            } else {
                                Image(uiImage: defaultPosterImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImageP(posterImage: $posterImage, defaultPoster: defaultPosterImage)
                        }
                        Spacer()
                    }
                }
                .padding(.top)

                // Form Fields
                Group {
                    LabeledTextField(label: "Full Name", text: $profileViewModel.currentProfile.fullName)
                    LabeledTextField(label: "Experience", text: $profileViewModel.currentProfile.experience)
                    LabeledTextField(label: "Description", text: $profileViewModel.currentProfile.descript)
                    LabeledTextField(label: "Mobile Number", text: $profileViewModel.currentProfile.mobileno, keyboardType: .numberPad)
                    
                    VStack(alignment: .leading,spacing: 10){
                        Text("Gender")
                            .font(.system(size: 18))
                        Picker("Select Gender", selection: $profileViewModel.currentProfile.gender) {
                            ForEach(genders, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }

                    DatePicker(
                        "Date of Birth",
                        selection: $profileViewModel.currentProfile.dob,
                        displayedComponents: [.date]
                    )
                    .font(.system(size: 18))

                    LabeledTextField(label: "Address", text: $profileViewModel.currentProfile.address)
                    LabeledTextField(label: "Pincode", text: $profileViewModel.currentProfile.pincode, keyboardType: .numberPad)
                    LabeledTextField(label: "Department", text: $profileViewModel.currentProfile.department)
                    LabeledTextField(label: "Speciality", text: $profileViewModel.currentProfile.speciality)
                    LabeledTextField(label: "Cabin Number", text: $profileViewModel.currentProfile.cabinNo)
                }

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

                        do {
                            try await profileViewModel.AddDepartment(
                                department: profileViewModel.currentProfile.department,
                                speciality: profileViewModel.currentProfile.speciality,
                                cabinNo: profileViewModel.currentProfile.cabinNo
                            )
                            print("Department updated successfully")
                        } catch {
                            print("Error updating department: \(error.localizedDescription)")
                        }
                    }
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Edit Profile")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color("paleBlue"))
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Edit Profile")
    }
}

struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 18))
            
            TextField("Enter \(label)", text: $text, axis: .vertical)
                .padding()
                .textFieldStyle(.automatic)
                .frame(height: 50)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding(.vertical, 5)
        }
    }
}



//------- - - -----------  - - - -------- - - - ----------

//
//import SwiftUI
//import MobileCoreServices
//import UniformTypeIdentifiers
//
//// MARK: - Main Profile Edit View
//struct Profile_Edit: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var viewModel: AuthViewModel
//    @EnvironmentObject var profileViewModel: DoctorViewModel
//
//    @State private var isImagePickerPresented = false
//    @State private var posterImage: UIImage?
//    @State private var defaultPosterImage: UIImage = UIImage(named: "profilePictureDefault")!
//
//    let genders = ["Male", "Female", "Other"]
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Profile Picture").font(.headline)) {
//                    ProfileImageView(posterImage: $posterImage, defaultPosterImage: defaultPosterImage)
//                        .onTapGesture {
//                            isImagePickerPresented.toggle()
//                        }
//                        .sheet(isPresented: $isImagePickerPresented) {
//                            ImagePicker(posterImage: $posterImage, defaultPoster: defaultPosterImage)
//                        }
//                }
//
//                Section(header: Text("Personal Information").font(.headline)) {
//                    LabeledTextField(label: "Full Name", text: $profileViewModel.currentProfile.fullName)
//                    LabeledTextField(label: "Experience", text: $profileViewModel.currentProfile.experience)
//                    LabeledTextField(label: "Description", text: $profileViewModel.currentProfile.descript)
//                    LabeledTextField(label: "Mobile Number", text: $profileViewModel.currentProfile.mobileno, keyboardType: .numberPad)
//                    
//                    Picker("Gender", selection: $profileViewModel.currentProfile.gender) {
//                        ForEach(genders, id: \.self) { Text($0) }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//
//                    DatePicker("Date of Birth", selection: $profileViewModel.currentProfile.dob, displayedComponents: [.date])
//                }
//
//                Section(header: Text("Contact Details").font(.headline)) {
//                    LabeledTextField(label: "Address", text: $profileViewModel.currentProfile.address)
//                    LabeledTextField(label: "Pincode", text: $profileViewModel.currentProfile.pincode, keyboardType: .numberPad)
//                }
//
//                Section(header: Text("Professional Details").font(.headline)) {
//                    LabeledTextField(label: "Department", text: $profileViewModel.currentProfile.department)
//                    LabeledTextField(label: "Speciality", text: $profileViewModel.currentProfile.speciality)
//                    LabeledTextField(label: "Cabin Number", text: $profileViewModel.currentProfile.cabinNo)
//                }
//
//                Section {
//                    Button("Edit Profile") {
//                        updateProfile()
//                    }
//                    .buttonStyle(PrimaryButtonStyle())
//                }
//            }
//            .navigationTitle("Edit Profile")
//        }
//    }
//
//    // MARK: - Helper Functions
//    private func updateProfile() {
//        Task {
//            profileViewModel.updateProfile(
//                profileViewModel.currentProfile,
//                posterImage: posterImage ?? defaultPosterImage,
//                userId: viewModel.currentUser?.id
//            ) {
//                print("Profile updated successfully")
//            }
//
//            do {
//                try await profileViewModel.AddDepartment(
//                    department: profileViewModel.currentProfile.department,
//                    speciality: profileViewModel.currentProfile.speciality,
//                    cabinNo: profileViewModel.currentProfile.cabinNo
//                )
//                print("Department updated successfully")
//            } catch {
//                print("Error updating department: \(error.localizedDescription)")
//            }
//        }
//        presentationMode.wrappedValue.dismiss()
//    }
//}
//
//// MARK: - Custom Components
//struct LabeledTextField: View {
//    let label: String
//    @Binding var text: String
//    var keyboardType: UIKeyboardType = .default
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//            Text(label)
//                .font(.system(size: 18))
//            
//            TextField("Enter \(label)", text: $text)
//                .padding()
//                .textFieldStyle(.roundedBorder)
//                .keyboardType(keyboardType)
//        }
//    }
//}
//
//struct ProfileImageView: View {
//    @Binding var posterImage: UIImage?
//    var defaultPosterImage: UIImage
//
//    var body: some View {
//        if let posterImage = posterImage {
//            Image(uiImage: posterImage)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 120, height: 120)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//        } else {
//            Image(uiImage: defaultPosterImage)
//                .resizable()
//                .scaledToFill()
//                .frame(width: 120, height: 120)
//                .clipShape(Circle())
//                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
//        }
//    }
//}
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Binding var posterImage: UIImage?
//    var defaultPoster: UIImage
//
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//            if let image = info[.originalImage] as? UIImage {
//                parent.posterImage = image
//            }
//            picker.dismiss(animated: true)
//        }
//    }
//}
//
//struct PrimaryButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .foregroundColor(.white)
//            .padding()
//            .background(Color.blue.cornerRadius(10))
//            .scaleEffect(configuration.isPressed ? 0.95 : 1)
//    }
//}
//
//// MARK: - Preview
//struct Profile_Edit_Previews: PreviewProvider {
//    static var previews: some View {
//        Profile_Edit()
//            .environmentObject(DoctorViewModel())
//            .environmentObject(AuthViewModel())
//    }
//}
