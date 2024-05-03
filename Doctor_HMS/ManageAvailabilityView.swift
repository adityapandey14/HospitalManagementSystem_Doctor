//
//  ManageAvailabilityView.swift
//  Doctor_HMS
//
//  Created by ChiduAnush on 03/05/24.
//

import SwiftUI

struct ManageAvailabilityView: View {
    @State private var selectedDate: Date = Date()
    @State private var selectedSlots: [Int: Bool] = [:] // Dictionary to track selected slots
    
    let timeSlots = ["09:00 AM", "10:00 AM", "11:00 AM", "01:00 PM", "02:00 PM", "03:00 PM"]
    
    var body: some View {
        ScrollView {
            VStack {
                // Calendar view to select the date
                DatePicker("Select a date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .tint(Color("paleBlue"))
                
                // List of slots
                VStack {
                    ForEach(0..<timeSlots.count, id: \.self) { index in
                        Button(action: {
                            // Toggle the selection state for this slot
                            selectedSlots[index] = !(selectedSlots[index] ?? false)
                        }) {
                            HStack {
                                Text(timeSlots[index])
                                    .font(.system(size: 20))
                                Spacer()
                                Image(systemName: selectedSlots[index] ?? false ? "checkmark.square.fill" : "checkmark.square")
                                    .foregroundColor(selectedSlots[index] ?? false ? Color("paleBlue") : .gray)
                                    .font(.system(size: 20))
                            }
                            .padding()
                            .background(selectedSlots[index] ?? false ? Color("paleBlue").opacity(0.2) : Color(uiColor: .systemBackground))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                
                // Submit button
                Button(action: {
                    // Handle the submission of selected slots
                    submitAvailability()
                }) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("paleBlue"))
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }
    
    func submitAvailability() {
        // Here you would handle the submission of the selected slots
        // For example, you could send them to a server or save them locally
        print("Selected slots for \(selectedDate): \(selectedSlots)")
    }
}

#Preview {
    ManageAvailabilityView()
}

