//
//  ContentView.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 19/04/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    var body: some View {
        //Imageview() use this for image upload and retrival
        Group {
            if $viewModel.userSession.wrappedValue != nil{
                HomepageComplete()
            } else {
                loginView()
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
    
}
