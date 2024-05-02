//
//  Homepage.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 22/04/24.
//

import SwiftUI

struct Homepage: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State var currentDateMonth : String = ""
    @State var todayDate : Date = Date()
    
    let todayPatientNos:Int = 03
    
    @State var dayDate: [DayDateInfo] = []
    @State var selectedDateIndex:Int = 0
    
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
        
        VStack{
            
            //profile image bar.
            HStack{
                Image("userimage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
                    .clipShape(Circle())
                
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text(currentDateMonth)
                        .foregroundStyle(Color.primary)
                        .font(.custom("", size: 18))
                    
                })
                Spacer()
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                //                    .fontWeight(.regular)
                    .padding(14)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            }
            .padding(.horizontal, 25)
            
            
            //good mornign and texts.
            HStack{
                VStack(alignment: .leading, spacing: 10){
                    Text("Good Morning Dr. Smith")
                        .font(.system(size: 22))
                    
                    Text("You have \(todayPatientNos) Patients Today")
                        .font(.system(size: 22))
                    //                        .fontWeight(.medium)
                        .foregroundStyle(Color("paleBlue"))
                    
                }
                .padding(.top, 40)
                
                Spacer()
            }
            .padding(.horizontal, 25)
            
            
            //dates of the week
        }
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
        .onAppear {
            let date = Date()
            
            var dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM, YYYY"
            self.currentDateMonth = dateFormatter.string(from: date)
            
            getDaysOfWeek()
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

