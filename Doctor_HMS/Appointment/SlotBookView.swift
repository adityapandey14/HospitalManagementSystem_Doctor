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
                .opacity(isBooked ? 0.2 : 1.0)
                .disabled(isBooked)  // Disable if booked
        }
        .frame(width: 90, height: 50)  // Set the size of the button
    }
}

struct SlotBookView: View {
    //   let doctor: DoctorModel
    let times = ["9:00 AM", "10:00 AM", "11:00 AM", "12:00 AM", "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM", "5:00 PM"]
    @State private var showConfirmationAlert = false
    
    @State private var selectedDate = Date()
    @State private var bookedSlots: [String] = []
    @State private var selectedSlot: String? = nil
    @State private var text: String = ""
    
    let placeholder: String = "Write your reason"
    
    var body: some View {
        NavigationStack {
            ScrollView {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding(.horizontal)
                    .tint(Color("paleBlue"))
                    .onChange(of: selectedDate) { _ in
                        selectedSlot = nil
                        fetchBookedSlots()  // Fetch slots when date changes
                    }
                
                
                HStack {
                    Text("Chose the slot you are not free: ")
                        .font(.subheadline)
                    Spacer()
                }
                .padding()
                
                VStack {
                    ForEach(times, id: \.self) { time in
                        let isBooked = bookedSlots.contains(time)
                        let isSelected = selectedSlot == time
                        
                        Button(action: {
                            if !isBooked {
                                selectedSlot = time  // Set the selected slot
                            }
                        }) {
                            HStack {
                                Text(time)
                                    .font(.system(size: 20))
                                Spacer()
                                Image(systemName: isSelected ? "checkmark.square.fill" : "checkmark.square")
                                    .foregroundColor(isSelected ? Color("paleBlue") : .gray)
                                    .font(.system(size: 20))
                            }
                            .padding()
                            .background(isSelected ? Color("paleBlue").opacity(0.2) : Color(uiColor: .systemBackground))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(isBooked)
                    }
                }
                .padding(.horizontal)
                
                
                Button("Reserve Busy Slots") {
                    if let selectedSlot = selectedSlot {
                        createBooking( date: selectedDate, slot: selectedSlot)
                        showConfirmationAlert = true
                    }
                }
                .padding()
                
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color.paleBlue)
                .cornerRadius(10)
                .padding()
                .disabled(selectedSlot == nil)  // Disable if no slot is selected
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Slot Reserved "),
                        dismissButton: .default(Text("Great!"))
                    )
                }
                
            }
            .navigationBarTitle("Manage Availability", displayMode: .inline)
        }
        .onAppear {
            fetchBookedSlots()  // Fetch initial data
        }
    }
    
    func fetchBookedSlots() {
        let db = Firestore.firestore()
        let formattedDate = selectedDate.formatted(date: .numeric, time: .omitted)
        
        db.collection("appointments")
            .whereField("DoctorID", isEqualTo: Auth.auth().currentUser?.uid)
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
    
    func createBooking( date: Date, slot: String) {
        let db = Firestore.firestore()
        
        let appointmentData: [String: Any] = [
            "Date": date.formatted(date: .numeric, time: .omitted),
            "DoctorID": Auth.auth().currentUser?.uid,
            "PatientID": Auth.auth().currentUser?.uid,
            "TimeSlot": slot,
            "isComplete": false,
            "reason": "busy"
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


#Preview {
    SlotBookView()
}









