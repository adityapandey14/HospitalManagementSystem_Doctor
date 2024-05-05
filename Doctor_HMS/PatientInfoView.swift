//
//  PatientInfoView.swift
//  Doctor_HMS
//
//  Created by ChiduAnush on 05/05/24.
//

import SwiftUI

struct PatientInfoView: View {
    
    @State private var selectedSegment = 0
    let patientName: String
    
    @State var doctorAppointmentNotes: String = ""
    
    var body: some View {
        ScrollView {
            VStack {
                
                //Patient profile pic, name(age and gender), call button, and mail button
                HStack(spacing: 18) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 60)
                        .opacity(0.8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(patientName)")
                            .font(.system(size: 20))
                        HStack(spacing: 0) {
                            Text("Age")
                                .font(.system(size: 13))
                                .opacity(0.5)
                            Image("dot")
                            Text("Gender")
                                .font(.system(size: 13))
                                .opacity(0.5)
                        }
                    }
                    Spacer()
                    //call and email
                    HStack(spacing: 15) {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "phone")
                                .tint(Color("paleBlue"))
                                .font(.system(size: 23))
                        })
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Image(systemName: "envelope")
                                .tint(Color("paleBlue"))
                                .font(.system(size: 23))
                        })
                        
                        
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top)

                // Segmented display: Information, Records, Prescribe
                Picker("Patient Info", selection: $selectedSegment) {
                    Text("Information").tag(0)
                    Text("Records").tag(1)
                    Text("Prescribe").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 25)
                .padding(.vertical)
                
                if selectedSegment == 0 {
                    AppointmentInfo()
                        .padding(.top)
                        .padding(.horizontal, 25)
                } else if selectedSegment == 1 {
                    Text("Patient Records")
                } else if selectedSegment == 2 {
                    Prescription(doctorAppointmentNotes: $doctorAppointmentNotes)
                        .padding(.top)
                        .padding(.horizontal, 25)
                } else {
                    Text("select a Tab")
                }
            }
            .navigationTitle("Patient Details")
        }
        
        
        
    }
}

#Preview {
    PatientInfoView(patientName: "Patient Name")
}

struct AppointmentInfo: View {
    var body: some View {
        HStack {
            Label(
                title: {
                    Text("Emergency call")
                        .font(.system(size: 18))
                },
                icon: {
                    Image(systemName: "light.beacon.max")
                        .foregroundStyle(Color(uiColor: .systemRed))
                        .font(.title2)
                }
            )
            Spacer()
            Text("+91 12345 67890")
                .font(.system(size: 18))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Blood Group")
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "drop")
                        .foregroundStyle(Color(uiColor: .systemRed))
                }
                HStack(alignment: .center, spacing: 3) {
                    Text("B")
                        .font(.system(size: 50, weight: .light))
                    Text("+ve")
                        .font(.system(size: 25, weight: .light))
                        .padding(.top, 15)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("Sleep Time")
                        .font(.system(size: 15))
                    Spacer()
                    Image(systemName: "moon")
                        .foregroundStyle(Color(uiColor: .systemPurple))
                        .fontWeight(.medium)
                }
                HStack(alignment: .center, spacing: 3) {
                    Text("7")
                        .font(.system(size: 50, weight: .light))
                    Text("hours")
                        .font(.system(size: 25, weight: .light))
                        .padding(.top, 15)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        
        VStack (spacing: 10){
            HStack {
                Text("Appointment Detials")
                    .font(.system(size: 17))
                    .opacity(0.8)
                Spacer()
            }
            HStack {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
                    .font(.system(size: 18))
                Spacer()
            }
        }
        .padding(.top)
        
        VStack (spacing: 10){
            HStack {
                Text("Allergies")
                    .font(.system(size: 17))
                    .opacity(0.8)
                Spacer()
            }
            HStack {
                Text("Lorem, ipsum, peanuts.")
                    .font(.system(size: 18))
                Spacer()
            }
        }
        .padding(.top)

    }
}

struct Prescription: View {
    @Binding var doctorAppointmentNotes: String
    
    var body: some View {
        VStack(spacing: 40) {
//            // Medication details
//            HStack {
//                Text("Medication:")
//                    .font(.headline)
//                    .foregroundColor(.black)
//                TextField("Enter medication name", text: .constant(""))
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//            .padding(.top)
//            
//            HStack {
//                Text("Dosage:")
//                    .font(.headline)
//                    .foregroundColor(.black)
//                TextField("e.g., 1 tablet", text: .constant(""))
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//            }
//            .padding(.top)
            
//            //Prescription notes
//            Text("Notes:")
//                .font(.headline)
//                .foregroundColor(.black)
            TextField("Write your notes for this appointment...", text: $doctorAppointmentNotes, axis: .vertical)
                .padding()
                .textFieldStyle(.automatic)
                .frame(height: 150)
                .background(Color(uiColor: .secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            
            // Submit button
            Button(action: {
                // Handle prescription submission
            }) {
                VStack(spacing: 10) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                        .fontWeight(.medium)
                        .font(.title2)
                        .padding()
                        .padding(.top, -4)
                        .background(Color("paleBlue"))
                        .clipShape(Circle())
                    
                    Text("Upload Prescription")
                        .foregroundStyle(Color.primary)
                        .opacity(0.8)
                    
                }
            }
        }
        
    }
}
