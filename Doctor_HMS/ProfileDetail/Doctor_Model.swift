//
//  Doctor_Model.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 30/04/24.
//

import Foundation
import SwiftUI

struct HealthRecord: Equatable, Codable{
    var filename: String
    var downloadURL: String
}
struct DoctorM: Equatable, Codable{
    
    var fullName : String
    var descript : String
    var gender: String
    var mobileno: String
    var experience :String
    var qualification:String
    var dob:Date
    var address:String
    var pincode:String
    var department : String
    var speciality : String
    var cabinNo : String
    var profilephoto: String?
    
}



