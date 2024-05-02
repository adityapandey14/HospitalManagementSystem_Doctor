//
//  User.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 21/04/24.
//

import Foundation

struct User : Identifiable , Codable {
    let id : String
    let email : String
    
//    var initials: String {
//        let formatter = PersonNameComponentsFormatter()
//        if let components = formatter.personNameComponents(from: fullName) {
//            formatter.style = .abbreviated
//            return formatter.string(from: components)
//        }
//        
//        return ""
//    }
}


extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString , email: "an6189@srmist.edu.in")
}
