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
    func updateDepartment(department: String, speciality: String, cabinNo: String) async throws {
        let db = Firestore.firestore()
        
        // Get the current user ID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        // Data to add to the Firestore document
        let data: [String: Any] = [
            "department": department,
            "speciality": speciality,
            "cabinNo": cabinNo,
            "doctorId": userId
        ]
        
        do {
            // Add a new document to the "department" collection
            let _ = try await db.collection("department").addDocument(data: data)
            print("Department added successfully")
        } catch {
            print("Error adding document: \(error.localizedDescription)")
            throw error  // Re-throw the error for handling at a higher level
        }
    }




}
