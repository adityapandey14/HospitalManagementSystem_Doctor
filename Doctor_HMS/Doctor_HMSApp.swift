//
//  Doctor_HMSApp.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 19/04/24.
//

import SwiftUI
import Firebase

@main
struct Doctor_HMSApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject var profileviewModel = DoctorViewModel()
    @StateObject var presviewmodel = PrescriptionViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
     init(){ //to make tab bar have green accent on selected bar icon
        // FirebaseApp.configure()
         if #available(iOS 15.0, *) {
             let appearance = UITabBarAppearance()
             appearance.selectionIndicatorTintColor = UIColor.green
             UITabBar.appearance().scrollEdgeAppearance = appearance
         }
     }
     
     var body: some Scene {
         WindowGroup {
        //     onboardingPageSwiftUIView()
             ContentView()
                 .environmentObject(viewModel)
                 .environmentObject(profileviewModel)
                 .environmentObject(presviewmodel)
         }
     }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
