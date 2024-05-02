//
//  AuthViewModel.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 22/04/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseStorage


protocol AuthenticationFormProtocol {
    var FormIsValid: Bool { get }
}

enum AuthError: Error {
    case noCurrentUser
    case notAdmin
    case CodeIsNotCorrect
    // Add other error cases as needed
}
@MainActor
class AuthViewModel: ObservableObject {
    
    // This is firebaseAuth user
    @Published var userSession : FirebaseAuth.User?
    
    
    // This is our user
    @Published var currentUser: User?
   
    
    init() {
    self.userSession = Auth.auth().currentUser
      
       
        Task {
            await fetchUser()
        }
    }
    
    
    func signIn(withEmail email: String , password: String) async throws {
            do {
                // Check if the email exists in the admin collection before attempting sign-in
                let isAdmin = try await checkIfAdmin(email: email)
                guard isAdmin else {
                    throw AuthError.notAdmin
                }
                
                // Perform sign-in if the user is an admin
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                self.userSession = result.user
                await fetchUser()
            } catch {
                print("DEBUG: Failed to log in with error \(error.localizedDescription)")
            }
        }
        func checkIfAdmin(email: String) async throws -> Bool {
            // Query Firestore to check if the email exists in the admin collection
            let querySnapshot = try await Firestore.firestore().collection("doctor").whereField("email", isEqualTo: email).getDocuments()
            
            // If there is at least one document with the given email, return true (user is admin)
            return !querySnapshot.documents.isEmpty
        }
    
    func createUser(withEmail email : String , password: String , fullName: String ) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid , fullName: fullName, email: email)
            // here user store data which you can't store directly on the firebase you have to store in form of json like raw data format with key value pair
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("patient").document(user.id).setData(encodedUser)
            
            //This is how we got information uploaded to firebase
            //first we go to firestore.firestore then collection there we got user then we create document using user id then set all the data of the user
            await fetchUser()
            //we need to fetch user because the above code will upload data into firebase and it will take some time to upload
            //and it won't go to next line until that process is complete that is why we use await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    
    
    func checkCode(code: String) async throws -> Bool {
        let firestore = Firestore.firestore()

        // Query Firestore to check if the code exists in the codeGenerator collection
        let querySnapshot = try await firestore
            .collection("codeGenerator")
            .whereField("code", isEqualTo: code)
            .getDocuments()

        // If there is at least one document with the given code, delete them
        if !querySnapshot.documents.isEmpty {
            // Asynchronously delete all matching documents
            try await withThrowingTaskGroup(of: Void.self) { group in
                for document in querySnapshot.documents {
                    group.addTask {
                        try await document.reference.delete()
                    }
                }
            }
            return true
        }

        // Always return false, regardless of whether the code existed or not
        return false
    }

    
    
    func signOut() {
        do {
          
            try Auth.auth().signOut()
            self.userSession = nil   //wipes out user session and teakes us back to login screen
            self.currentUser = nil//signOUt user on backened
              // wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() {
           
        let userId = Auth.auth().currentUser!.uid
        Auth.auth().currentUser?.delete()
        self.userSession = nil
        self.currentUser = nil


                Firestore.firestore().collection("doctor").document(userId).delete() { err in
                    if let err = err {
                        print("error: \(err)")
                    } else {
                        print("Deleted user in db users")
                        Storage.storage().reference(forURL: "gs://myapp.appspot.com").child("doctor").child(userId).delete() { err in
                            if let err = err {
                                print("error: \(err)")
                            } else {
                                print("Deleted User image")
                                Auth.auth().currentUser!.delete { error in
                                   if let error = error {
                                       print("error deleting user - \(error)")
                                   } else {
                                        print("Account deleted")
                                   }
                                }
                            }
                        }
                    }
                }
    }
    

    
    
    func changePassword(password : String) {
        Task{
            
            await fetchUser()
        }
       Auth.auth().currentUser?.updatePassword(to: password) { err in
            if let err = err {
                print("error: \(err)")
            } else {
                print("Password has been updated")
                self.signOut()
            }
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //If there is data it will go and fetch data if there is not then it will return will wasting api calls
        guard let snapshot = try? await Firestore.firestore().collection("doctor").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
       // print("DEBUG: Current user is \(String(describing: self.currentUser))")
    }
    
    
    func sendPasswordResetEmail(to email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset email: \(error.localizedDescription)")
            } else {
                print("Password reset email sent successfully to \(email)")
            }
        }
    }
    
}
