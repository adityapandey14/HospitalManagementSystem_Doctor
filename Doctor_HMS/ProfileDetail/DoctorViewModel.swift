//
//  DoctorViewModel.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 30/04/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class DoctorViewModel: ObservableObject {
   
    @Published var currentProfile: DoctorM = DoctorM(
        fullName: "\(AuthViewModel().currentUser?.fullName )",
        descript : "",
        gender: "",
        mobileno: "",
        experience: "",
        qualification:"",
        dob:Date(),
        address:"",
        pincode:"",
        department: "",
        speciality: "",
        cabinNo: "",
        profilephoto: nil
    )
    
    private let db = Firestore.firestore()
    @EnvironmentObject var viewModel: AuthViewModel
    
    func fetchProfile(userId: String?) {
        guard let userId = userId, !userId.isEmpty else {
            print("Invalid userId")
            return
        }
        
        db.collection("doctor").document(userId).getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
            } else {
                if let document = document, document.exists {
                    do {
                        self.currentProfile = try document.data(as: DoctorM.self)
                    } catch {
                        print("Error decoding Profile: \(error)")
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }

    
    
    func updateProfile(_ profile: DoctorM, posterImage: UIImage?, userId: String?, completion: @escaping () -> Void) {
        var updatedProfile = profile
        
        // Check if there is a new profile photo to upload
        if let image = posterImage, let imageData = image.jpegData(compressionQuality: 0.1) {
            let storageRef = Storage.storage().reference().child("profilephoto").child(UUID().uuidString)
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "")")
                        return
                    }
                    
                    updatedProfile.profilephoto = downloadURL.absoluteString
                    
                    self.updateProfileDocument(updatedProfile, userId: userId, completion: completion)
                }
            }
        } else {
            // No new profile photo to upload, directly update profile document
            updateProfileDocument(updatedProfile, userId: userId, completion: completion)
        }
    }
    

    func updateProfileDocument(_ profile: DoctorM, userId: String?, completion: @escaping () -> Void) {
        guard let userId = userId else {
            print("User ID is nil")
            return
        }
        
        let profileRef = self.db.collection("doctor").document(userId)
        
        do {
            try profileRef.setData(from: profile, merge: true) { error in
                if let error = error {
                    print("Error updating profile document: \(error.localizedDescription)")
                } else {
                    print("Profile document updated successfully!")
                    self.fetchProfile(userId: userId)
                    completion()
                }
            }
        } catch {
            print("Error updating profile document: \(error.localizedDescription)")
        }
    }
    
  

    // This function is now marked with 'async' since it performs an asynchronous operation
//    func AddDepartment(department: String, speciality: String, cabinNo: String) async throws {
//        let db = Firestore.firestore()
//        let departmentLower = department
//
//        // Get the current user ID
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User not authenticated")
//            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
//        }
//
//        // Data to be used in Firestore document
//        let data: [String: Any] = [
//            "department":  department,
//            "speciality": speciality,
//            "cabinNo": cabinNo,
//            "doctorId": userId
//        ]
//
//        do {
//            // Query the subcollection to check if a document with the same doctorId already exists
//  
//                // If no document with the doctorId exists, create a new one
//                try await db.collection("department")
//                            .document("abcd")
//                            .collection("allSpecialisation")
//                            .addDocument(data: data)
//                print("Department created successfully")
//            
//
//        } catch {
//            print("Error updating or creating document: \(error.localizedDescription)")
//            throw error  // Re-throw the error for higher-level handling
//        }
//    }

    
    
//    func updateDepartment(department: String, speciality: String, cabinNo: String) async throws {
//        let db = Firestore.firestore()
//
//        // Get the current user ID
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User not authenticated")
//            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
//        }
//
//        // Convert department to lowercase
//        let departmentLower = department.lowercased()
//
//        // Data to be used in Firestore document
//        let data: [String: Any] = [
//            "department": departmentLower,
//            "speciality": speciality,
//            "cabinNo": cabinNo,
//            "doctorId": userId
//        ]
//
//        do {
//            // Query the subcollection to check if a document with the same doctorId already exists
//            let querySnapshot = try await db.collection("department")
//                                           .document(departmentLower)
//                                           .collection("allSpecialisation")
//                                           .whereField("doctorId", isEqualTo: userId)
//                                           .getDocuments()
//
//            if let existingDocument = querySnapshot.documents.first {
//                // If a document with the doctorId exists, update it with new data
//                try await db.collection("department")
//                            .document(departmentLower)
//                            .collection("allSpecialisation")
//                            .document(existingDocument.documentID)
//                            .updateData(data)
//                print("Department updated successfully")
//            }
//
//        } catch {
//            print("Error updating or creating document: \(error.localizedDescription)")
//            throw error  // Re-throw the error for higher-level handling
//        }
//    }

    
    func AddDepartment(department: String, speciality: String, cabinNo: String) async throws {
        let db = Firestore.firestore()
        
        // Get the current user ID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        db.collection("department")
            .whereField("departmentTypes", isEqualTo: department)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error querying department: \(error.localizedDescription)")
                    return
                }
                
                if let existingDepartment = querySnapshot?.documents.first {
                    // The department exists. Check if the specialisation already exists for this user.
                    let specialisationCollection = existingDepartment.reference.collection("allSpecialisation")
                    
                    specialisationCollection
                        .whereField("doctorId", isEqualTo: userId)
                        .getDocuments { (specSnapshot, error) in
                            if let error = error {
                                print("Error querying specialisations: \(error.localizedDescription)")
                                return
                            }
                            
                            if let existingSpecialisation = specSnapshot?.documents.first {
                                // If the specialisation already exists, update it.
                                existingSpecialisation.reference.updateData([
                                    "cabinNo": cabinNo,
                                    "speciality": speciality
                                ]) { error in
                                    if let error = error {
                                        print("Error updating specialisation: \(error.localizedDescription)")
                                    } else {
                                        print("Successfully updated existing specialisation")
                                    }
                                }
                            } else {
                                // If it doesn't exist, create a new one.
                                specialisationCollection.addDocument(data: [
                                    "doctorId": userId,
                                    "cabinNo": cabinNo,
                                    "speciality": speciality,
                                    "department": department
                                ]) { error in
                                    if let error = error {
                                        print("Error adding specialisation: \(error.localizedDescription)")
                                    } else {
                                        print("Successfully added new specialisation")
                                    }
                                }
                            }
                        }
                } else {
                    // The department does not exist. Create it and then add the specialisation.
                    let newDepartment = db.collection("department").document() // Auto-generated ID
                    
                    newDepartment.setData([
                        "departmentTypes": department
                    ]) { error in
                        if let error = error {
                            print("Error creating new department: \(error.localizedDescription)")
                            return
                        }
                        
                        newDepartment.collection("allSpecialisation").addDocument(data: [
                            "doctorId": userId,
                            "cabinNo": cabinNo,
                            "speciality": speciality,
                            "department": department
                        ]) { error in
                            if let error = error {
                                print("Error adding specialisation to new department: \(error.localizedDescription)")
                            } else {
                                print("Successfully created new department and added specialisation")
                            }
                        }
                    }
                }
            }
    }




}
