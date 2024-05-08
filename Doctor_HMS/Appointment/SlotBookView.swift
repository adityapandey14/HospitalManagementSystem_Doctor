//
//  SlotBookView.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 08/05/24.
//




import SwiftUI
import Firebase
import FirebaseAuth

struct TimeButton: View {
    var time: String
    var isBooked: Bool
    var isSelected: Bool
    var isSelectable: Bool
    var action: () -> Void
    
    
    var body: some View {
        
        Button(action: {
            if isSelectable {
                action()  // Perform action if selectable
            }
        }) {
            RoundedRectangle(cornerRadius: 15)
                .fill(isBooked ? Color.gray.opacity(0.5) : (isSelected ? Color.blue : Color.white))
                .overlay(
                    Text(time)
                        .font(.headline)
                        .foregroundColor(isBooked ? .gray : (isSelected ? .white : .blue))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isBooked ? Color.gray : Color.blue, lineWidth: 2)
                )
                .opacity(isBooked ? 0.5 : 1.0)
                .disabled(isBooked)  // Disable if booked
        }
        .frame(width: 90, height: 50)  // Set the size of the button
    }
}

struct SlotBookView: View {
    let doctor: DoctorModel
    let times = ["9:00 AM", "10:00 AM", "11:00 AM", "12:00 AM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"]
    @State private var showConfirmationAlert = false
    
    @State private var selectedDate = Date()
    @State private var bookedSlots: [String] = []
    @State private var selectedSlot: String? = nil
    @State private var text: String = ""
    
    let placeholder: String = "Write your reason for consultation"
    
    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .padding()
                .onChange(of: selectedDate) { _ in
                    fetchBookedSlots()  // Fetch slots when date changes
                }
            
            Text("Available Slots")
                .font(.headline)
                .padding(.bottom, 30)
            
//            Divider()
//                .padding(.bottom, 30)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(times, id: \.self) { time in
                    let isBooked = bookedSlots.contains(time)
                    let isSelected = selectedSlot == time
                    
                    TimeButton(
                        time: time,
                        isBooked: isBooked,
                        isSelected: isSelected,
                        isSelectable: !isBooked
                    ) {
                        selectedSlot = time  // Set the selected slot
                    }
                }
                .foregroundStyle(Color.black)
            }
            .padding(.bottom)
            
            ZStack {
                
//                if text.isEmpty {
//                    Text(placeholder)
//                        .foregroundStyle(Color.black)
//                        .padding(.horizontal)
//                        .padding(.vertical)
//                }
//                TextField(text : $text)
//                    .frame(minWidth: 0, maxWidth: 360, minHeight: 0, maxHeight: 120)
//                    .border(Color.myGray, width: 1)
//                    .padding()
                
                TextField("Consultation reason", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(width: 390)
            }
            Button("Book Appointment") {
                if let selectedSlot = selectedSlot {
                    createBooking(doctor: doctor, date: selectedDate, slot: selectedSlot)
                    showConfirmationAlert = true
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(selectedSlot == nil)  // Disable if no slot is selected
            .alert(isPresented: $showConfirmationAlert) {
                          Alert(
                              title: Text("Appointment Confirmed"),
                              message: Text("Your appointment with \(doctor.fullName) on \(selectedDate) has been booked."),
                              dismissButton: .default(Text("OK"))
                          )
                      }
            
        }
        .onAppear {
            fetchBookedSlots()  // Fetch initial data
        }
    }
    
    func fetchBookedSlots() {
        let db = Firestore.firestore()
        let formattedDate = selectedDate.formatted(date: .numeric, time: .omitted)
        
        db.collection("appointments")
            .whereField("DoctorID", isEqualTo: doctor.id)
            .whereField("Date", isEqualTo: formattedDate)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching booked slots: \(error.localizedDescription)")
                } else {
                    let slots = querySnapshot?.documents.compactMap {
                        $0.data()["TimeSlot"] as? String
                    } ?? []
                    bookedSlots = slots  // Update booked slots
                }
            }
    }
    
    func createBooking(doctor: DoctorModel, date: Date, slot: String) {
        let db = Firestore.firestore()
        
        let appointmentData: [String: Any] = [
            "Date": date.formatted(date: .numeric, time: .omitted),
            "DoctorID": doctor.id,
            "PatientID": Auth.auth().currentUser?.uid ?? "",
            "TimeSlot": slot,
            "isComplete": false,
            "reason": "Consultation"
        ]
        
        db.collection("appointments").addDocument(data: appointmentData) { error in
            if let error = error {
                print("Error creating booking: \(error.localizedDescription)")
            } else {
                fetchBookedSlots()  // Re-fetch the booked slots after booking
            }
        }
    }
}


struct SlotBookView_Previews: PreviewProvider {
    static var previews: SlotBookView {
        let dummyDoctor = DoctorModel(
            id: "1",
            fullName: "Dr. Jane Doe",
            descript: "Expert in cardiology",
            gender: "Female",
            mobileno: "1234567890",
            experience: "10 years",
            qualification: "MD, Cardiology",
            dob: Date(timeIntervalSince1970: 0),
            address: "123 Main St, Springfield",
            pincode: "123456",
            department: "Cardiology",
            speciality: "Cardiologist",
            cabinNo: "101",
            profilephoto: nil
        )
        
        return SlotBookView(doctor: dummyDoctor)
    }
}












//            ZStack {
//                RoundedRectangle(cornerRadius: 28)
//                    .fill(LinearGradient(
//                        gradient: Gradient(colors: [Color.blue.opacity(1), Color.blue.opacity(0.5)]),
//                        startPoint: .leading,
//                        endPoint: .trailing))
//                    .frame(width: 361, height: 180)
//                    .shadow(color: Color.black.opacity(0.15), radius: 20)
//
//                HStack {
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text(doctor.name)
//                            .font(.title.bold())
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                            .padding()
//                            .frame(alignment: .top)
//
//                        Text(doctor.specialisation)
//                            .font(.callout)
//                            .foregroundColor(.white)
//
//                        Text(doctor.degree)
//                            .font(.body)
//                            .foregroundColor(.white)
//                        Text("Experience: \(doctor.experience) years")
//                            .font(.body)
//                            .foregroundColor(.white)
//                    }
//                    Image(systemName: "person.circle.fill")
//                        .foregroundColor(.white)
//                        .font(.system(size: 60))
//                        .padding(.trailing, 10)
//                }
//                .padding(.leading, 30)
//                Spacer()
//            }
//            .frame(width: 380, height: 200)
