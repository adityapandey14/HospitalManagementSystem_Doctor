//
//  ProfilePage.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 30/04/24.
//

import SwiftUI

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileViewModel: DoctorViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isEditSuccessful = false
    @State private var navigateToNewPassword = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(gradient: Gradient(colors: [Color("e8f2fd"), Color("ffffff")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Title
                    Text("Profile")
                        .font(.system(size: 29))
                        .padding(.trailing, 250)
                        .padding(.top, 100)
                        .bold()
                    
                    // Profile content
                    HStack {
                        // Profile image
                        ProfileImageView()
                        
                        // Profile details
                        ProfileDetailsView()
                            .padding(.trailing, 38)
                        
                        // Edit button
                        EditButtonView(isEditSuccessful: $isEditSuccessful)
                    }
                    .padding(.top, 15)
                    
                    // Buttons
                    ProfileButtonsView(navigateToNewPassword: $navigateToNewPassword)
                }
                .padding(.top, 110)
            }
        }
        .onAppear {
            try? profileViewModel.fetchProfile(userId: viewModel.currentUser?.id)
        }
    }
}

struct ProfileImageView: View {
    @EnvironmentObject var profileViewModel: DoctorViewModel
    
    var body: some View {
        HStack {
            if let posterURL = profileViewModel.currentProfile.profilephoto {
                AsyncImage(url: URL(string: posterURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .cornerRadius(10.0)
                            .clipShape(Circle())
                            .padding([.leading, .bottom, .trailing])
                    default:
                        ProgressView()
                            .frame(width: 50, height: 50)
                            .padding([.leading, .bottom, .trailing])
                    }
                }
            } else {
                Image(uiImage: UIImage(named: "default_hackathon_poster")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10.0)
                    .clipShape(Circle())
                    .padding([.leading, .bottom, .trailing])
            }
        }
    }
}

struct ProfileDetailsView: View {
    @EnvironmentObject var profileViewModel: DoctorViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(profileViewModel.currentProfile.fullName)
                .font(.system(size: 17))
                .foregroundColor(.black)
                .bold()
            Text(viewModel.currentUser?.email ?? "email")
                .font(.system(size: 13))
                .foregroundColor(.white)
                .padding(.bottom, 1)
                .italic()
            Text(profileViewModel.currentProfile.mobileno)
                .font(.system(size: 13))
                .foregroundColor(.black)
        }
    }
}

struct EditButtonView: View {
    @Binding var isEditSuccessful: Bool
    
    var body: some View {
        Button(action: { isEditSuccessful = true }) {
            Image(systemName: "square.and.pencil")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
                .padding(.leading)
        }
        .sheet(isPresented: $isEditSuccessful) {
            Profile_Edit()
        }
    }
}

struct ProfileButtonsView: View {
    @Binding var navigateToNewPassword: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 310, height: 150)
                .cornerRadius(10)
                .padding(.top, 70)
            
            VStack {
                NavigationLink(destination: AnnouncementsView()) {
                    HStack {
                        Image(systemName: "doc.fill")
                            .resizable()
                            .frame(width: 18, height: 20)
                        Text("Announcements")
                            .bold()
                        Image(systemName: "chevron.right")
                    }
                    .padding(.top, 60)
                }
                
                // Other buttons...
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(DoctorViewModel())
            .environmentObject(AuthViewModel())
    }
}
