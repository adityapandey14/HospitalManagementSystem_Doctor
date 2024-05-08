//
//  Homepage.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 22/04/24.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct Homepage: View {
    @EnvironmentObject var profileViewModel: DoctorViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    @State var currentDateMonth: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, yyyy"
        return dateFormatter.string(from: Date())
    }()
    @State var todayDate: Date = Date()
    @State var dayDate: [DayDateInfo] = []
    @State var selectedDateIndex: Int = 0
    let currentUserId = Auth.auth().currentUser?.uid
    @ObservedObject var appointViewModel = AppointmentViewModel()

    var selectedDate: Date {
        return Calendar.current.date(byAdding: .day, value: selectedDateIndex, to: todayDate)!
    }

    var numberOfPatientsToday: Int {
//        let appointmentsForDate = appointViewModel.appointments.filter { appointment in
//            if let appointmentDate = appointment.date {
//                return Calendar.current.isDate(appointmentDate, inSameDayAs: selectedDate)
//            }
//            return false // Handle case where appointment date is nil
//        }
        let selectedDateAppointments = appointViewModel.appointments.filter { $0.doctorID == currentUserId && $0.date == selectedDate.formatted(date: .numeric, time: .omitted)}

        return selectedDateAppointments.count
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Profile image bar.
                HStack {
                    HStack {
                        if let posterURL = profileViewModel.currentProfile.profilephoto {
                            AsyncImage(url: URL(string: posterURL)) { phase in
                                switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
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
                                .frame(width: 60, height: 60)
                                .cornerRadius(10.0)
                                .clipShape(Circle())
                                .padding([.leading, .bottom, .trailing])
                        }
                    }
                    Spacer()
                    Text(currentDateMonth)
                        .foregroundColor(Color.primary)
                        .font(.custom("", size: 18))
                    Spacer()
                    NavigationLink(destination: ManageAvailabilityView()) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(Color.primary)
                            .font(.title2)
                            .padding(14)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top)
                .onAppear(){
                    try? profileViewModel.fetchProfile(userId: viewModel.currentUser?.id)
                }

                
                // Good morning and texts.
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Good Morning " + profileViewModel.currentProfile.fullName)                            .font(.system(size: 22))
                        Text("You have \(numberOfPatientsToday) Patients Today")
                            .font(.system(size: 22))
                            .foregroundColor(Color("paleBlue"))
                    }
                    .padding(.top, 40)
                    Spacer()
                }
                .padding(.horizontal, 25)
                
                // Date show for 7 days
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(dayDate.indices, id: \.self) { index in
                            DateView(dateInfo: dayDate[index], isSelected: selectedDateIndex == index) {
                                selectedDateIndex = index
                            }
                        }
                    }
                    .padding()
                }
                
                // Appointment list for the selected date
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(appointViewModel.appointments.filter { $0.doctorID == currentUserId && $0.date == selectedDate.formatted(date: .numeric, time: .omitted)}) { appointment in
                            HStack(alignment: .top) {
                                Text(appointment.timeSlot)
                                    .padding()
                                Spacer()
                                AppointmentCard(appointment: appointment)
                            } //End of Horizontal Stack
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
            .onAppear {
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM, yyyy"
                currentDateMonth = dateFormatter.string(from: date)
                getDaysOfWeek()
                appointViewModel.fetchAppointments() // Fetch appointments when the view appears
            }
        }
    }
    
    func getDaysOfWeek() {
        let calendar = Calendar.current
        let todayDate = Date()
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: todayDate) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d"
                let dateFormatted = dateFormatter.string(from: date)
                dateFormatter.dateFormat = "EE"
                let dayFormatted = dateFormatter.string(from: date)
                let dayDateInfo = DayDateInfo(date: dateFormatted, day: dayFormatted)
                self.dayDate.append(dayDateInfo)
            }
        }
    }
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


struct AppointmentCard: View {
    let appointment: AppointmentModel
    @StateObject var patientViewModel = PatientViewModel.shared
    @State private var patientName: String = "Unknown"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let patient = patientViewModel.patientDetails.first(where: { $0.id == appointment.patientID }) {
                HStack{
                    Text(patient.fullName)
                        .font(.system(size: 18))
                    Spacer()
                }
                Text(String(calculateAge(from: patient.dob!)))
                    .font(.system(size: 14))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))

            } else {
                Text("Loading...")
                    .font(.system(size: 18))
                    .onAppear {
                        Task {
                            await patientViewModel.fetchPatientDetailsByID(patientID: appointment.patientID)
                        }
                    }
            }
            Text(appointment.reason)
                .font(.system(size: 14))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            NavigationLink(destination: PatientAndAppoinmentDetails(patient: patientViewModel.patientDetails.first(where: { $0.id == appointment.patientID }) ?? dummyPatient, appointment: appointment)) {
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
    }
    
    func calculateAge(from dob: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let ageComponents = calendar.dateComponents([.year, .month, .day, .hour], from: dob, to: now)
        
        if let years = ageComponents.year, years > 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else if let months = ageComponents.month, months > 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        } else if let days = ageComponents.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        } else if let hours = ageComponents.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        } else {
            return "0"
        }
    }


}


struct Homepage_Previews: PreviewProvider {
    static var previews: some View {
        let profileViewModel = DoctorViewModel()
        let viewModel = AuthViewModel()
        let appointViewModel = AppointmentViewModel()


        viewModel.currentUser = User(id: "1", email: "john.doe@example.com")

        let dummyAppointment = AppointmentModel(id: "1", date: "", doctorID: "1", patientID: "2", timeSlot: "10:00 AM", isComplete: false, reason: "Routine checkup")

        return Homepage()
            .environmentObject(profileViewModel)
            .environmentObject(viewModel)
            .environment(\.locale, .init(identifier: "en_US"))
            .environmentObject(appointViewModel)
            .previewDisplayName("Homepage Preview")    }
}


////
////  Homepage.swift
////  Doctor_HMS
////
////  Created by Aditya Pandey on 22/04/24.
////
//
//import SwiftUI
//import Firebase
//import FirebaseAuth
//
//struct Homepage: View {
//    @EnvironmentObject var viewModel : AuthViewModel
//    @State var currentDateMonth : String = ""
//    @State var todayDate : Date = Date()
//
//    @State var dayDate: [DayDateInfo] = []
//    @State var selectedDateIndex:Int = 0
//
//
//   let currentUserId = Auth.auth().currentUser?.uid
//
//    @ObservedObject var appointViewModel = AppointmentViewModel()
//
//
//
//
//    // Sample appointments
//        let sampleAppointments: [Appointment] = [
//            Appointment(date: Date(), patientName: "John Doe", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
//            Appointment(date: Date().addingTimeInterval(3600), patientName: "Jane Smith", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
//            Appointment(date: Date().addingTimeInterval(7200), patientName: "Alice Johnson", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
//            Appointment(date: Date().addingTimeInterval(10800), patientName: "Bob Brown", appointmentDetail: "Sore throat and pain near the ears. round head hurts."),
//             //Add more sample appointments as needed
//        ]
//
//    var selectedDate: Date {
//        return Calendar.current.date(byAdding: .day, value: selectedDateIndex, to: todayDate)!
//    }
//
//    var appointmentsForSelectedDate: [Appointment] {
//        return sampleAppointments.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
//    }
//
//    var numberOfPatientsToday: Int {
//            let appointmentsForDate = sampleAppointments.filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
//            return appointmentsForDate.count
//        }
//
//
//    var body: some View {
//
//
//        NavigationStack{
//            VStack{
//
//                //profile image bar.
//                HStack{
//                    Image("userimage")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 60)
//                        .clipShape(Circle())
//
//                    Spacer()
//                    Text(currentDateMonth)
//                        .foregroundStyle(Color.primary)
//                        .font(.custom("", size: 18))
//                    Spacer()
//                    NavigationLink(destination: ManageAvailabilityView()) {
//                        Image(systemName: "square.and.pencil")
//                            .foregroundStyle(Color.primary)
//                            .font(.title2)
//                            .padding(14)
//                            .background(Color(uiColor: .secondarySystemBackground))
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                    }
//
//
//                }
//                .padding(.horizontal, 25)
//                .padding(.top)
//
//
//                //good mornign and texts.
//                HStack{
//                    VStack(alignment: .leading, spacing: 10){
//                        Text("Good Morning Dr. Smith")
//                            .font(.system(size: 22))
//
//                        Text("You have \(numberOfPatientsToday) Patients Today")
//                            .font(.system(size: 22))
//                            .foregroundStyle(Color("paleBlue"))
//
//                    }
//                    .padding(.top, 40)
//
//                    Spacer()
//                }
//                .padding(.horizontal, 25)
//
//
//                //date show for 7 days
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 20) {
//                        ForEach(dayDate.indices, id: \.self) { index in
//                            DateView(dateInfo: dayDate[index], isSelected: selectedDateIndex == index) {
//                                if selectedDateIndex == index {
//                                    selectedDateIndex = index
//
//                                } else {
//                                    selectedDateIndex = index
//                                }
//                            }
//                        }
//                    }
//                    .padding()
//                }
//
//
//                ScrollView {
//                    LazyVStack(spacing: 20) {
//                        ForEach(appointViewModel.appointments.filter { $0.doctorID == currentUserId && $0.date == Date().formatted(date: .numeric, time: .omitted)}) { appointment in
//
//                            HStack(alignment: .top){
////                                Text("\(formattedTimeString(from: appointment.date))")
////                                    .font(.system(size: 15))
////                                    .padding(.top, 15)
////                                Spacer()
//                                Text(appointment.patientID)
//                                    .padding()
//                                AppointmentCard(appointment: appointment)
//
//                            }
//                        }  //End of for loop
//                    }
//                }
//                .padding(.horizontal, 25)
//
//
//
//            }
//            .onAppear {
//                let date = Date()
//
//                //var dateFormatter = DateFormatter()
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "MMM, YYYY"
//                self.currentDateMonth = dateFormatter.string(from: date)
//
//                getDaysOfWeek()
//            }
//        }
//
//    }
//
//
//
//    func getDaysOfWeek(){
//        let calendar = Calendar.current
//        let todayDate = Date()
//
//        for dayOffset in 0..<7 {
//            if let date = calendar.date(byAdding: .day, value: dayOffset, to: todayDate) {
//                let dateFormatter = DateFormatter()
//
//                dateFormatter.dateFormat = "d"
//                let dateFormatted = dateFormatter.string(from: date)
//
//                dateFormatter.dateFormat = "EE"
//                let dayFormatted = dateFormatter.string(from: date)
//
//                // Create a DayInfo instance and append it to the array
//                let dayDateInfo = DayDateInfo(date: dateFormatted, day: dayFormatted)
//                self.dayDate.append(dayDateInfo)
//            }
//        }
//    }
//
//    //for time on left side of appointment cards
//    private func formattedTimeString(from date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm a"
//        return dateFormatter.string(from: date)
//    }
//
//
//}
//
//
//#Preview {
//    Homepage()
//}
//
//
//
//
////MARK: struct for date design
//struct DateView: View {
//    let dateInfo: DayDateInfo
//    let isSelected: Bool
//    let onTap: () -> Void
//
//    var body: some View {
//        VStack {
//            Text(dateInfo.date)
//                .padding(18)
//                .background(isSelected ? Color("paleBlue") : Color(uiColor: .secondarySystemBackground))
//                .clipShape(Circle())
//                .foregroundColor(isSelected ? .white : .primary)
//                .onTapGesture {
//                    onTap()
//                }
//
//            Text(dateInfo.day)
//                .foregroundColor(isSelected ? .primary : .secondary)
//
//            if isSelected {
//                Circle()
//                    .fill(Color("paleBlue"))
//                    .frame(width: 8, height: 8)
//                    .padding(.top, -6)
//            }
//        }
//    }
//}
//
//
////MARK: struct for apppointment card
//struct AppointmentCard: View {
//    let appointment: AppointmentModel
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
////            Text("Patient: \(appointment.patientName)")
////                .font(.headline)
////            Text("Time: \(formattedTimeString(from: appointment.date))")
////                .font(.subheadline)
//
//            VStack(alignment: .leading, spacing: 3){
//                Text(appointment.patientID)
//                    .font(.system(size: 18))
//
//                Text("21 yo")
//                    .font(.system(size: 14))
//                    .foregroundStyle(Color(uiColor: .secondaryLabel))
//            }
//
//            Text(appointment.reason)
//                .font(.system(size: 14))
//                .foregroundStyle(Color(uiColor: .secondaryLabel))
//
////            NavigationLink(destination: PatientInfoView(patientName: appointment.patientName)) {
////                Text("View more Details")
////                    .font(.system(size: 15))
////                    .fontWeight(.medium)
////                    .foregroundStyle(Color("paleBlue"))
////            }
//
//
//        }
//        .padding(13)
//        .padding(.bottom, 4)
//        .background(Color(uiColor: .secondarySystemBackground))
//        .cornerRadius(20)
//        .frame(width: 260)
//    }
//
////    private func formattedTimeString(from date: Date) -> String {
////        let dateFormatter = DateFormatter()
////        dateFormatter.dateFormat = "h:mm a"
////        return dateFormatter.string(from: date)
////    }
//}
