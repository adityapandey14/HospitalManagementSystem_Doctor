//
//  Homepage.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 22/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Homepage: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State var currentDateMonth : String = ""
    @State var todayDate : Date = Date()
    
    @State var dayDate: [DayDateInfo] = []
    @State var selectedDateIndex:Int = 0
    
    
   let currentUserId = Auth.auth().currentUser?.uid
    
    @ObservedObject var appointViewModel = AppointmentViewModel()
    
    

    
    // Sample appointments
        let sampleAppointments: [Appointment] = [
            Appointment(date: Date(), patientName: "John Doe", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
            Appointment(date: Date().addingTimeInterval(3600), patientName: "Jane Smith", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
            Appointment(date: Date().addingTimeInterval(7200), patientName: "Alice Johnson", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
            Appointment(date: Date().addingTimeInterval(10800), patientName: "Bob Brown", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
             //Add more sample appointments as needed
        ]
        
    var selectedDate: Date {
        return Calendar.current.date(byAdding: .day, value: selectedDateIndex, to: todayDate)!
    }
        
    var appointmentsForSelectedDate: [Appointment] {
        return sampleAppointments.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    var numberOfPatientsToday: Int {
            let appointmentsForDate = sampleAppointments.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            return appointmentsForDate.count
        }

    
    var body: some View {
        //        HStack {
        //            Spacer()
        //            Button(action: {
        //                viewModel.signOut()
        //            }) {
        //                Image(systemName: "gear")
        //                    .resizable()
        //                    .frame(width: 30, height: 30)
        //                    .foregroundColor(Color.blue)
        //            }
        //            .padding(.all, 10)
        //
        //        }
        
        NavigationStack{
            VStack{
                
                //profile image bar.
                HStack{
                    Image("userimage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60)
                        .clipShape(Circle())
                    
                    Spacer()
                    Text(currentDateMonth)
                        .foregroundStyle(Color.primary)
                        .font(.custom("", size: 18))
                    Spacer()
                    NavigationLink(destination: ManageAvailabilityView()) {
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(Color.primary)
                            .font(.title2)
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    
                }
                .padding(.horizontal, 25)
                .padding(.top)
                
                
                //good mornign and texts.
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        Text("Good Morning Dr. Smith")
                            .font(.system(size: 22))
                        
                        Text("You have \(numberOfPatientsToday) Patients Today")
                            .font(.system(size: 22))
                            .foregroundStyle(Color("paleBlue"))
                        
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
                .padding(.horizontal, 25)
                
                
                //date show for 7 days
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(dayDate.indices, id: \.self) { index in
                            DateView(dateInfo: dayDate[index], isSelected: selectedDateIndex == index) {
                                if selectedDateIndex == index {
                                    selectedDateIndex = index
                                } else {
                                    selectedDateIndex = index
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(appointmentsForSelectedDate) { appointment in

                            HStack(alignment: .top){
                                Text("\(formattedTimeString(from: appointment.date))")
                                    .font(.system(size: 15))
                                    .padding(.top, 15)
                                Spacer()
                                AppointmentCard(appointment: appointment)
                            }
                        }  //End of for loop
                    }
                }
                .padding(.horizontal, 25)
                
                
                
            }
            .onAppear {
                let date = Date()
                
                //var dateFormatter = DateFormatter()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM, YYYY"
                self.currentDateMonth = dateFormatter.string(from: date)
                
                getDaysOfWeek()
            }
        }
        
    }
    
    
    
    func getDaysOfWeek(){
        let calendar = Calendar.current
        let todayDate = Date()
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: todayDate) {
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateFormat = "d"
                let dateFormatted = dateFormatter.string(from: date)
                
                dateFormatter.dateFormat = "EE"
                let dayFormatted = dateFormatter.string(from: date)
                
                // Create a DayInfo instance and append it to the array
                let dayDateInfo = DayDateInfo(date: dateFormatted, day: dayFormatted)
                self.dayDate.append(dayDateInfo)
            }
        }
    }
    
    //for time on left side of appointment cards
    private func formattedTimeString(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    
}


#Preview {
    Homepage()
}




//MARK: struct for date design
struct DateView: View {
    let dateInfo: DayDateInfo
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            Text(dateInfo.date)
                .padding(18)
                .background(isSelected ? Color("paleBlue") : Color(uiColor: .secondarySystemBackground))
                .clipShape(Circle())
                .foregroundColor(isSelected ? .white : .primary)
                .onTapGesture {
                    onTap()
                }
            
            Text(dateInfo.day)
                .foregroundColor(isSelected ? .primary : .secondary)
            
            if isSelected {
                Circle()
                    .fill(Color("paleBlue"))
                    .frame(width: 8, height: 8)
                    .padding(.top, -6)
            }
        }
    }
}


//MARK: struct for apppointment card
struct AppointmentCard: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
//            Text("Patient: \(appointment.patientName)")
//                .font(.headline)
//            Text("Time: \(formattedTimeString(from: appointment.date))")
//                .font(.subheadline)
            
            VStack(alignment: .leading, spacing: 3){
                Text(appointment.patientName)
                    .font(.system(size: 18))
                
                Text("21 yo")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
            
            Text(appointment.appointmentDetail)
                .font(.system(size: 14))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            NavigationLink(destination: PatientInfoView(patientName: appointment.patientName)) {
                Text("View more Details")
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .foregroundStyle(Color("paleBlue"))
            }

            
        }
        .padding(13)
        .padding(.bottom, 4)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
        .frame(width: 260)
    }
    
//    private func formattedTimeString(from date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "h:mm a"
//        return dateFormatter.string(from: date)
//    }
}
