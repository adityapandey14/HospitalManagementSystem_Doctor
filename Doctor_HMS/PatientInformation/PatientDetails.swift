//
//  PatientDetails.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 06/05/24.
//






import Foundation
import SwiftUI
import FirebaseFirestore

struct PatientModel: Identifiable, Equatable, Codable {
    var id: String
    var fullName: String
    var email: String
    
    var gender: String
    var mobileno: String
    
    var dob: Date?
    var address: String
    var pincode: String
    var emergencyContact: String
    var bloodGroup: String
    
    var profilephoto: String?
}

class PatientViewModel: ObservableObject {
    @Published var patientDetails: [PatientModel] = []
    private let db = Firestore.firestore()
    static let shared = PatientViewModel()

    func fetchPatientDetails() async {
        do {
            let snapshot = try await db.collection("patient").getDocuments()
            
            var details: [PatientModel] = []
            for document in snapshot.documents {
                let data = document.data()
                let id = document.documentID
                
                let fullName = data["fullName"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let gender = data["gender"] as? String ?? ""
                let mobileno = data["mobileno"] as? String ?? ""
                
                let dob = data["dob"] as? Timestamp
                let dateOfBirth = dob?.dateValue()
                let address = data["address"] as? String ?? ""
                let pincode = data["pincode"] as? String ?? ""
                let emergencyContact = data["emergencycontact"] as? String ?? ""
                let bloodGroup = data["bloodgroup"] as? String ?? ""
                
                let profilephoto = data["profilephoto"] as? String
                
                let patientDetail = PatientModel(
                    id: id,
                    fullName: fullName,
                    email: email,
                    gender: gender,
                    mobileno: mobileno,
                    dob: dateOfBirth,
                    address: address,
                    pincode: pincode,
                    emergencyContact: emergencyContact,
                    bloodGroup: bloodGroup,
                    profilephoto: profilephoto
                )
                
                details.append(patientDetail)
            }
            
            DispatchQueue.main.async {
                self.patientDetails = details
            }
        } catch {
            print("Error fetching patient details: \(error.localizedDescription)")
        }
    }

    func fetchPatientDetailsByID(patientID: String) async {
        do {
            let document = try await db.collection("patient").document(patientID).getDocument()
            
            if document.exists {
                if let data = document.data() {
                    let dob = data["dob"] as? Timestamp
                    let dateOfBirth = dob?.dateValue()
                    
                    let patientDetail = PatientModel(
                        id: document.documentID,
                        fullName: data["fullName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        gender: data["gender"] as? String ?? "",
                        mobileno: data["mobileno"] as? String ?? "",
                        dob: dateOfBirth,
                        address: data["address"] as? String ?? "",
                        pincode: data["pincode"] as? String ?? "",
                        emergencyContact: data["emergencycontact"] as? String ?? "",
                        bloodGroup: data["bloodgroup"] as? String ?? "",
                        profilephoto: data["profilephoto"] as? String
                    )
                    
                    DispatchQueue.main.async {
                        self.patientDetails = [patientDetail]
                    }
                }
            } else {
                print("Patient document does not exist")
            }
        } catch {
            print("Error fetching patient details by ID: \(error.localizedDescription)")
        }
    }
}

let dummyPatient = PatientModel(
    id: "1",
    fullName: "Dummy Patient",
    email: "dummy@example.com",
    gender: "Male",
    mobileno: "1234567890",
    dob: Date(timeIntervalSince1970: 0), // Example date (Jan 1, 1970)
    address: "123 Medical Lane",
    pincode: "123456",
    emergencyContact: "9876543210",
    bloodGroup: "O+",
    profilephoto: "https://www.example.com/patient-profile.jpg" // Example image URL
)

struct PatientDetails: View {
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    PatientDetails()
}
