//
//  Prescription_Viewmodel.swift
//  Doctor_HMS
//
//  Created by Arnav on 06/05/24.
//

import SwiftUI
import Firebase

class PrescriptionViewModel: ObservableObject {
    @Published var patients = [Patient]()
    @Published var prescriptions = [Prescriptionn]()
    
    private var db = Firestore.firestore()
    
    func fetchPatients() {
        db.collection("patient").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            self.patients = documents.map { queryDocumentSnapshot -> Patient in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                let name = data["fullName"] as? String ?? ""
                return Patient(id: id, name:name)
            }
        }
    }
    
    func addPrescription(patientID: String, medicines: [Medicine], instructions: String) {
        var medicineData = [[String: Any]]()
        for medicine in medicines {
            let data: [String: Any] = [
                "name": medicine.name,
                "dosage": medicine.dosage
                // Add more medicine details as needed
            ]
            medicineData.append(data)
        }
        
        let prescriptionData: [String: Any] = [
            "patientID": patientID,
            "medicines": medicineData,
            "instructions": instructions
            // Add more prescription details as needed
        ]
        
        // Set the document ID explicitly to patientID
        db.collection("prescriptions").document(patientID).setData(prescriptionData)
    }



}
