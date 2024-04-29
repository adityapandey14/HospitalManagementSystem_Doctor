import SwiftUI
import FirebaseAuth

struct signUpView: View {
   
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var confirmPassword = ""
    @State private var code = ""
   
    @EnvironmentObject var viewModel : AuthViewModel
    
    @State private var isSignUpSuccessful = false
    
    var body: some View {
        NavigationView{
            VStack{
                //login and signup option
//                HStack{
////                    VStack{
////                        NavigationLink(destination: loginView()){
////                            Text("Login")
////                                .foregroundColor(.black)
////                                .font(AppFont.mediumSemiBold)
////                        }
////                        Rectangle()
////                            .frame(width: 100, height: 3)
////                            .foregroundStyle(Color.clear)
////                    }
//                    Spacer()
//                    VStack{
//                        NavigationLink(destination: signUpView()){
//                            Text("Sign up")
//                                .foregroundColor(.black)
//                                .font(AppFont.mediumSemiBold)
//                        }
//                        Rectangle()
//                            .frame(width: 100, height: 3)
//                            .foregroundStyle(Color.accent)
//                    }
//                }
                
                //sign up details
                VStack(alignment: .leading){
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Image("homePageLogo")
                                .resizable()
                                .frame(width: 100, height: 100)
                            
                            Text("Join MedNex")
                                .font(.system(size: 30).weight(.light))
                            Text("Let’s start with your basic information.")
                                .font(.system(size: 17).weight(.light))
                        }
                       
                    }

                    VStack(alignment: .leading){
//                        Text("Email address")
//                            .font(AppFont.mediumReg)
                        TextField("Email address", text: $email)
                            .listRowBackground(Color.background)
                            .textFieldStyle(.plain)
                            .cornerRadius(8)
                            .autocapitalization(.none)
                            .underlineTextField()
                    }
                    .listRowBackground(Color.clear)
                    
                    VStack(alignment: .leading){
//                        Text("Full Name")
//                            .font(AppFont.mediumReg)
                        TextField("Full name", text: $fullName)
                            .cornerRadius(8)
                            .underlineTextField()
                    }
                    .padding(.top)
                    .listRowBackground(Color.clear)
                    
                    VStack(alignment: .leading){
//                        Text("Password")
//                            .font(AppFont.mediumReg)
                        SecureField("Password", text: $password)
                            .cornerRadius(8)
                            .underlineTextField()
                    }
                    .padding(.top)
                    .listRowBackground(Color.clear)
                    
                    VStack(alignment: .trailing){
                        Text("At least 6 characters")
                            .foregroundColor(.midNightExpress)
                            .padding(.leading,170)
                    }
                    
                    VStack(alignment: .leading){
//                        Text("Confirm Password")
//                            .font(AppFont.mediumReg)
                        ZStack(alignment : .trailing) {
                            VStack{
                                SecureField("Confirm password", text: $confirmPassword)
                                    .cornerRadius(8)
                                    .underlineTextField()
                                
                                SecureField("Your private Code", text: $code)
                                    .cornerRadius(8)
                                    .underlineTextField()
                            }
                          
                        
                            if !password.isEmpty && !confirmPassword.isEmpty {
                                if password == confirmPassword {
                                    Image(systemName: "checkmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(.systemGreen))
                                } else {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(.systemRed))
                                }
                            }
                        }
                    }
                    .padding(.top)
                    .listRowBackground(Color.clear)
                }
                .padding(.top)
                
                Spacer()
                
                //button
                Button(action: signUp) {
                    NavigationLink(destination: loginView() ){
                        
                        Button {
                            Task {
                                try await viewModel.createUser(withEmail: email, password: password, fullName: fullName , code : code)
                            }
                        } label: {
                            Text("Sign up")
                                .foregroundColor(.white)
                                .frame(width: 325, height: 50)
                                .background(Color.midNightExpress)
                                .cornerRadius(10)
                        }
                      
                    }
                }
                .disabled(!FormIsValid)
                .opacity(FormIsValid ? 1.0 : 0.5)
//                .sheet(isPresented: $isSignUpSuccessful) {
//                    Profile_Create(email:email, password:password,fullName: fullName)
//                }
                
                HStack{
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    NavigationLink(destination: loginView()){
                        Text("Sign in")
                            .foregroundColor(.asparagus)
                            .padding(.top)
                    }
                }
                
            }
            .padding()
            .background(Color.solitude)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
    }
    
    private func signUp() {
        isSignUpSuccessful = true
    }
}

extension signUpView: AuthenticationFormProtocol {
    var FormIsValid: Bool {
        return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 5
            && password == confirmPassword
            && !fullName.isEmpty
    }
}

struct signUpView_Previews: PreviewProvider {
    static var previews: some View {
        signUpView()
    }
}



