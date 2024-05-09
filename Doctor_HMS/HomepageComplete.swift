//
//  HomepageComplete.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 30/04/24.
//

import SwiftUI

struct HomepageComplete: View {
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(named: "paleBlue")
        UITabBar.appearance().tintColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            Homepage()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
//            Appointment()
//                .tabItem {
//                    Label("Appointment", systemImage: "person.crop.rectangle.fill")
//                        .padding(.top)
//                }
            
//            AddPrescriptionView()
//                .tabItem {
//                    Label("Prescription", systemImage: "stethoscope")
//                        .padding(.top)
//                }
            
//            appointView()
//                .tabItem {
//                    Label("appointView", systemImage: "folder.fill")
//                        .padding(.top)
//                }
//
//            Profile_Edit()
//                .tabItem {
//                    Label("ProfileEdit", systemImage: "folder.fill")
//                        .padding(.top)
//                }
            
            
            SlotBookView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Reserve Slots")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Profile")
                }
            
        }
        .accentColor(Color("paleBlue"))
    }
}

#Preview {
    HomepageComplete()
}

