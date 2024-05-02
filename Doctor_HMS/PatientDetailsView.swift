//
//  PatientDetailsView.swift
//  Doctor_HMS
//
//  Created by ChiduAnush on 02/05/24.
//

import Foundation
import SwiftUI



struct PatientDetailsView: View {
    let patientName: String
    
    var body: some View {
        Text("Details for \(patientName)")
            .navigationTitle("Patient Details")
    }
}

#Preview {
    PatientDetailsView(patientName: "Manish")
}
