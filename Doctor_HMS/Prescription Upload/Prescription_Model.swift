//
//  Prescription_Model.swift
//  Doctor_HMS
//
//  Created by Arnav on 06/05/24.
//

import Foundation

struct Patient {
    let id: String
    let name: String
    // Add more details as needed
}

struct Prescriptionn {
    let patientID: String
    let medicines: [Medicine]
    let instructions: String
   
}

struct Medicine {
    let name: String
    let dosage: String
    
}

