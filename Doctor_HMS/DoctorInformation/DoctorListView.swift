//
//  DoctorListView.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 06/05/24.
//

//
//  DoctorModel.swift
//  Patient_HMS
//
//  Created by Arnav on 30/04/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct DoctorModel: Identifiable, Equatable, Codable {
    var id: String
    var fullName: String
    var descript: String
    var gender: String
    var mobileno: String
    var experience: String
    var qualification: String
    var dob: Date?
    var address: String
    var pincode: String
    var department: String
    var speciality: String
    var cabinNo: String
    var profilephoto: String?
}

class DoctorInformationModel: ObservableObject {
    @Published var doctorDetails: [DoctorModel] = []
    private let db = Firestore.firestore()
    static let shared = DoctorInformationModel()

    func fetchDoctorDetails() async {
        do {
            let snapshot = try await db.collection("doctor").getDocuments()
            
            var details: [DoctorModel] = []
            for document in snapshot.documents {
                let data = document.data()
                let id = document.documentID
                
                // Extract values safely, providing default values or handling unexpected types
                let fullName = data["fullName"] as? String ?? ""
                let descript = data["descript"] as? String ?? ""
                let gender = data["gender"] as? String ?? ""
                let mobileno = data["mobileno"] as? String ?? ""
                let experience = data["experience"] as? String ?? "" // Fixed field name
                let qualification = (data["qualification"] as? String ?? "") // Fixed expected type
                let dob = data["dob"] as? Timestamp // If Firestore stores Date as Timestamp
                let dateOfBirth = dob?.dateValue() // Convert Timestamp to Date
                let address = data["address"] as? String ?? ""
                let pincode = data["pincode"] as? String ?? ""
                let department = data["department"] as? String ?? ""
                let speciality = data["speciality"] as? String ?? ""
                let cabinNo = data["cabinNo"] as? String ?? ""
                let profilephoto = data["profilephoto"] as? String

                let doctorDetail = DoctorModel(
                    id: id,
                    fullName: fullName,
                    descript: descript,
                    gender: gender,
                    mobileno: mobileno,
                    experience: experience,
                    qualification: qualification,
                    dob: dateOfBirth, // Set converted date
                    address: address,
                    pincode: pincode,
                    department: department,
                    speciality: speciality,
                    cabinNo: cabinNo,
                    profilephoto: profilephoto
                )
                
                details.append(doctorDetail)
            }
            
            // Update the property within the main thread
            DispatchQueue.main.async {
                self.doctorDetails = details
            }
        } catch {
            print("Error fetching Doctor details: \(error.localizedDescription)")
        }
    }

    func fetchDoctorDetailsByID(doctorID: String) async {
        do {
            let document = try await db.collection("doctor").document(doctorID).getDocument()
            
            if document.exists {
                if let data = document.data() {
                    let dob = data["dob"] as? Timestamp // Convert to Timestamp
                    let dateOfBirth = dob?.dateValue() // Convert Timestamp to Date
                    
                    let doctorDetail = DoctorModel(
                        id: document.documentID,
                        fullName: data["fullName"] as? String ?? "",
                        descript: data["descript"] as? String ?? "",
                        gender: data["gender"] as? String ?? "",
                        mobileno: data["mobileno"] as? String ?? "",
                        experience: data["experience"] as? String ?? "",
                        qualification: data["qualification"] as? String ?? "",
                        dob: dateOfBirth,
                        address: data["address"] as? String ?? "",
                        pincode: data["pincode"] as? String ?? "",
                        department: data["department"] as? String ?? "",
                        speciality: data["speciality"] as? String ?? "",
                        cabinNo: data["cabinNo"] as? String ?? "",
                        profilephoto: data["profilephoto"] as? String ?? ""
                    )
                    
                    // Update the property on the main thread
                    DispatchQueue.main.async {
                        self.doctorDetails = [doctorDetail]
                    }
                }
            } else {
                print("Doctor document does not exist")
            }
        } catch {
            print("Error fetching Doctor details: \(error.localizedDescription)")
        }
    }
}






let dummyDoctor = DoctorModel(
    id: "1",
    fullName: "Dr. John Smith",
    descript: "Expert in cardiology",
    gender: "Male",
    mobileno: "1234567890",
    experience: "10 years",
    qualification: "MD",
    dob: Date(timeIntervalSince1970: 0),  // Example date (Jan 1, 1970)
    address: "123 Medical Lane",
    pincode: "123456",
    department: "Cardiology",
    speciality: "Cardiologist",
    cabinNo: "101",
    profilephoto: "https://www.example.com/doctor-profile.jpg"  // Example image URL
)



//if let skillType = skillViewModel.skillTypes.first(where: { $0.id == skillUid }) {
//    VStack {
//        if let detail = skillType.skillOwnerDetails.first(where: { $0.id == skillOwnerDetailsUid }) {
//


 // For loading remote images asynchronously

// This is a view for displaying individual doctor's details
struct DoctorDetailView: View {
    let doctor: DoctorModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
//            if let photoURL = doctor.profilephoto, let url = URL(string: photoURL) {
//                WebImage(url: url) // Requires SDWebImageSwiftUI
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//            } else {
//                Circle()
//                    .fill(Color.gray)
//                    .frame(width: 100, height: 100)
//                    .overlay(Text("No Image").foregroundColor(.white))
//            }

            Text("Name: \(doctor.fullName)")
                .font(.headline)
            
            Text("Gender: \(doctor.gender)")
                .font(.subheadline)

            Text("Experience: \(doctor.experience)")
                .font(.subheadline)
            
            Text("Qualification: \(doctor.qualification)")
                .font(.subheadline)
            
            Text("Speciality: \(doctor.speciality)")
                .font(.subheadline)

            Spacer()
        }
        .padding()
        .navigationTitle("Doctor Details")
    }
}

// This is a view for displaying a list of doctors
struct DoctorListView: View {
    @ObservedObject var viewModel = DoctorInformationModel.shared

    var body: some View {
        NavigationView {
            List(viewModel.doctorDetails) { doctor in
                NavigationLink(destination: DoctorDetailView(doctor: doctor)) {
                    HStack {
//                        if let photoURL = doctor.profilephoto, let url = URL(string: photoURL) {
//                            WebImage(url: url) // Requires SDWebImageSwiftUI
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 50, height: 50)
//                                .clipShape(Circle())
//                        } else {
//                            Circle()
//                                .fill(Color.gray)
//                                .frame(width: 50, height: 50)
//                                .overlay(Text("No Image").foregroundColor(.white))
//                        }

                        VStack(alignment: .leading) {
                            Text(doctor.fullName)
                                .font(.headline)
                            
                            Text(doctor.speciality)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchDoctorDetails()
                }
            }
            .navigationTitle("Doctors List")
        }
    }
}


#Preview {
    DoctorListView()
}
