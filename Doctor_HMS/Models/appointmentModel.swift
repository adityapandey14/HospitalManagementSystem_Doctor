//
//  homeAppointmentModel.swift
//  Doctor_HMS
//
//  Created by ChiduAnush on 02/05/24.
//

import Foundation

struct Appointment: Identifiable {
    let id = UUID()
    let date: Date
    let patientName: String
    let appointmentDetail: String
}
