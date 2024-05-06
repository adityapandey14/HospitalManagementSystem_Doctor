//
//  HomepageComplete.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 30/04/24.
//

import SwiftUI

struct HomepageComplete: View {
    var body: some View {
        TabView {
            Homepage()
                .tabItem {
                    Label("Home", systemImage: "house")
                        .padding(.top)
                }
            
//            Appointment()
//                .tabItem {
//                    Label("Appointment", systemImage: "person.crop.rectangle.fill")
//                        .padding(.top)
//                }
            
            
            appointView()
                .tabItem {
                    Label("appointView", systemImage: "folder.fill")
                        .padding(.top)
                }
//
            Profile_Edit()
                .tabItem {
                    Label("ProfileEdit", systemImage: "folder.fill")
                        .padding(.top)
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .padding(.top)
                }
            
        }
    }
}

#Preview {
    HomepageComplete()
}

