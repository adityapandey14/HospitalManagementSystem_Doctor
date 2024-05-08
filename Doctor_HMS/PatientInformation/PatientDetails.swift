//
//  PatientDetails.swift
//  Doctor_HMS
//
//  Created by Aditya Pandey on 06/05/24.
//

import SwiftUI
import Foundation
import FirebaseFirestore
import MobileCoreServices
import QuickLook
import PDFKit
import FirebaseStorage

struct PatientModel: Identifiable, Equatable, Codable {
    var id: String
    var fullName: String
    var email: String
    
    var gender: String
    var mobileno: String
    
    var dob: Date?
    var address: String
    var pincode: String
    var emergencyContact: String
    var bloodGroup: String
    
    var profilephoto: String?
}

class PatientViewModel: ObservableObject {
    @Published var patientDetails: [PatientModel] = []
    private let db = Firestore.firestore()
    static let shared = PatientViewModel()
    

    func fetchPatientDetails() async {
        do {
            let snapshot = try await db.collection("patient").getDocuments()
            
            var details: [PatientModel] = []
            for document in snapshot.documents {
                let data = document.data()
                let id = document.documentID
                
                let fullName = data["fullName"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let gender = data["gender"] as? String ?? ""
                let mobileno = data["mobileno"] as? String ?? ""
                
                let dob = data["dob"] as? Timestamp
                let dateOfBirth = dob?.dateValue()
                let address = data["address"] as? String ?? ""
                let pincode = data["pincode"] as? String ?? ""
                let emergencyContact = data["emergencycontact"] as? String ?? ""
                let bloodGroup = data["bloodgroup"] as? String ?? ""
                
                let profilephoto = data["profilephoto"] as? String
                
                let patientDetail = PatientModel(
                    id: id,
                    fullName: fullName,
                    email: email,
                    gender: gender,
                    mobileno: mobileno,
                    dob: dateOfBirth,
                    address: address,
                    pincode: pincode,
                    emergencyContact: emergencyContact,
                    bloodGroup: bloodGroup,
                    profilephoto: profilephoto
                )
                
                details.append(patientDetail)
            }
            
            DispatchQueue.main.async {
                self.patientDetails = details
            }
        } catch {
            print("Error fetching patient details: \(error.localizedDescription)")
        }
    }

    func fetchPatientDetailsByID(patientID: String) async {
        do {
            let document = try await db.collection("patient").document(patientID).getDocument()
            
            if document.exists {
                if let data = document.data() {
                    let dob = data["dob"] as? Timestamp
                    let dateOfBirth = dob?.dateValue()
                    
                    let patientDetail = PatientModel(
                        id: document.documentID,
                        fullName: data["fullName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        gender: data["gender"] as? String ?? "",
                        mobileno: data["mobileno"] as? String ?? "",
                        dob: dateOfBirth,
                        address: data["address"] as? String ?? "",
                        pincode: data["pincode"] as? String ?? "",
                        emergencyContact: data["emergencycontact"] as? String ?? "",
                        bloodGroup: data["bloodgroup"] as? String ?? "",
                        profilephoto: data["profilephoto"] as? String
                    )
                    
                    DispatchQueue.main.async {
                        self.patientDetails = [patientDetail]
                    }
                }
            } else {
                print("Patient document does not exist")
            }
        } catch {
            print("Error fetching patient details by ID: \(error.localizedDescription)")
        }
    }
}

let dummyPatient = PatientModel(
    id: "1",
    fullName: "Dummy Patient",
    email: "dummy@example.com",
    gender: "Male",
    mobileno: "1234567890",
    dob: Date(timeIntervalSince1970: 0), // Example date (Jan 1, 1970)
    address: "123 Medical Lane",
    pincode: "123456",
    emergencyContact: "9876543210",
    bloodGroup: "O+",
    profilephoto: "https://www.example.com/patient-profile.jpg" // Example image URL
)

let dummyAppointment = AppointmentModel(
    id: "1",
    date: "",
    doctorID: "1",
    patientID: "2",
    timeSlot: "",
    isComplete: false,
    reason: "consultation"
)

struct PatientAndAppoinmentDetails: View {
    let patient: PatientModel
    let appointment: AppointmentModel
    @ObservedObject var appointmentviewmodel = AppointmentViewModel()
    @StateObject var patientViewModel = PatientViewModel.shared
    @EnvironmentObject var AuthviewModel:AuthViewModel
    @State private var healthRecordPDFData: Data? = nil
    @State private var selectedPDFName: String? = nil
    @State private var isDocumentPickerPresented = false
    @State private var uploadProgress: Double = 0.0
    @State private var isUploading: Bool = false
    @State private var uploadedDocuments: [StorageReference] = []
    @State private var searchText = ""
    @State private var isPDFLoading = false // Added state variable for PDF loading
    
    @State private var isPreviewPresented = false
    @State private var previewURL: URL?
    @EnvironmentObject var PrescriptionViewModel: PrescriptionViewModel
    @State private var selectedPatient: String = ""
    @State private var medicines: [MedicineInput] = [MedicineInput()]
    @State private var instructions: String = ""
   


    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    @State private var selectedSegment = 0
//    let patientName: String
    
//    @State var doctorAppointmentNotes: String = ""
    
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
                        Text("\(patient.fullName)")
                            .font(.system(size: 20))
                        HStack(spacing: 0) {
                            Text(String(calculateAge(from: patient.dob!)))
                                .font(.system(size: 13))
                                .opacity(0.5)
                            Image("dot")
                            Text(patient.gender)
                                .font(.system(size: 13))
                                .opacity(0.5)
                        }
                    }
                    Spacer()
                    //call and email
                    HStack(spacing: 15) {
                        Button(action: {
                                   // Replace with a valid phone number
                            let phoneNumber = patient.mobileno
                                   if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                                       UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                   } else {
                                       print("Unable to open URL")
                                   }
                               }) {
                                   Image(systemName: "phone")
                                       .tint(Color("paleBlue"))
                                        .font(.system(size: 23))
                               } // End of Button
                        
                        
//--------------------------------iMessage ----------------------------//
                        Button(action: {
                                    // Define the phone number to open in iMessage
                                    let phoneNumber = patient.mobileno
                                    
                                    // Construct the URL with the 'sms:' scheme
                                    if let url = URL(string: "sms:\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                                        // Open iMessage with the specified phone number
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    } else {
                                        print("Unable to open iMessage")
                                    }
                                }) {
                                    Image(systemName: "envelope")
                                        .tint(Color("paleBlue"))
                                         .font(.system(size: 23))
                                }
                        
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
                    VStack{
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
                            Text("+91 " + patient.emergencyContact)
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
                                    Text(patient.bloodGroup)
                                        .font(.system(size: 50, weight: .light))
                                    Text("ve")
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
                        
                        VStack (alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Appointment Details")
                                    .font(.system(size: 17))
                                    .opacity(0.8)
                                Spacer()
                            }
                            VStack(alignment: .leading) {
                                Text(appointment.reason)
                                    .font(.system(size: 18))
                                
                                Text("Time Slot: \(appointment.timeSlot)")
                                    .font(.system(size: 18))
                                    
                                Text("Status: \(appointment.isComplete ? "Completed" : "Pending")")
                                    .font(.system(size: 18))
                                    .foregroundColor(appointment.isComplete ? .green : .orange)
                                
                            // Accept appoint or delete appointment button
                                HStack {
                                    Button{
                                        appointmentviewmodel.deleteAppointment(appointmentId: appointment.id)
                                        
                                    } label : {
                                        Text("Delete")
                                            .foregroundStyle(Color.red)
                                    }
                                    
                                    Spacer()
                                    
                                    
                                    Button{
                                        appointmentviewmodel.markAppointmentAsComplete(appointmentId: appointment.id)
                                      
                                    } label : {
                                        Text("Completed")
                                    }
                                } //end of HStack
                                
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
                    .padding(.top)
                    .padding(.horizontal, 25)
                    
                } else if selectedSegment == 1 {
                    Text("Patient Records")
                    ZStack{
                        NavigationView {
                            Form {
                                Section{
                                    SearchBar(searchText: $searchText)

                                    ForEach(uploadedDocuments.indices, id: \.self) { index in
                                        let documentRef = uploadedDocuments[index]
                                        if searchText.isEmpty || documentRef.name.lowercased().contains(searchText.lowercased()) {
                                            HStack {
                                                Button(action: {
                                                    viewDocument(documentRef: documentRef)
                                                }) {
                                                    Text(documentRef.name)
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(Color.white)
                            }
                            
                            .background(Color.clear)
                        }
                        .scrollContentBackground(.hidden)
                        .onAppear {
                            fetchUploadedDocuments(id: patient.id)
                        }
                        .sheet(isPresented: $isPreviewPresented) {
                            if let previewURL = previewURL, let pdfDocument = PDFDocument(url: previewURL) {
                                PDFPreviewView(pdfDocument: pdfDocument)
                            } else {
                                Text("Error displaying PDF")
                            }
                        }

                        if isPDFLoading { // Show loading animation if PDF is loading
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(2)
                                .foregroundColor(.blue)
                        }
                    }
                    .background(Color.solitude)
                    
                } else if selectedSegment == 2 {
//                    Prescription(doctorAppointmentNotes: $doctorAppointmentNotes)
//                        .padding(.top)
//                        .padding(.horizontal, 25)
                    VStack {
                        
                        ForEach(medicines.indices, id: \.self) { index in
                            MedicineInputView(medicine: $medicines[index])
                        }
                        
                        Button(action: {
                            medicines.append(MedicineInput())
                        }, label: {
                            Text("Add Medicine")
                                .foregroundStyle(Color.paleBlue)
                                .frame(width: 360, height: 50)
                        })
                        .foregroundStyle(Color.paleBlue)
                        .frame(width: 360, height: 50)

                        
                        TextField("Instructions", text: $instructions)
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(10)
                            .padding(.top)
                        
                        Button("Add Prescription")
                        {
                            guard !selectedPatient.isEmpty && !medicines.isEmpty && !instructions.isEmpty else {
                                return
                            }
                            let medicineData = medicines.map { Medicine(name: $0.name, dosage: $0.dosage) }
                            PrescriptionViewModel.addPrescription(patientID: patient.id, medicines: medicineData, instructions: instructions)
                            
                            // Clear fields after adding prescription
                            selectedPatient = ""
                            medicines = [MedicineInput()]
                            instructions = ""
                        }
                        .frame(width: 360, height: 50)
                        .foregroundStyle(Color.white)
                        .background(Color.paleBlue)
                        .cornerRadius(10)
                        
                    }
                    .padding()
                    
                } else {
                    Text("select a Tab")
                }
            }
            .navigationTitle("Patient Details")
        }
        
        
//        VStack(alignment: .leading) {
//            Text("Patient Details")
//                .font(.title)
//                .padding(.bottom, 20)
//            
//            Text("Full Name: \(patient.fullName)")
//            Text("Email: \(patient.email)")
//            Text("Gender: \(patient.gender)")
//            Text("Mobile No: \(patient.mobileno)")
//            
//            if let dob = patient.dob {
//                Text("Date of Birth: \(Self.dateFormatter.string(from: dob))")
//            }
//            
//            Text("Address: \(patient.address)")
//            Text("Pincode: \(patient.pincode)")
//            Text("Emergency Contact: \(patient.emergencyContact)")
//            Text("Blood Group: \(patient.bloodGroup)")
//            
//            if let profilePhoto = patient.profilephoto {
//                // You can load and display the profile photo here
//                // Example:
//                // AsyncImage(url: URL(string: profilePhoto), placeholder: { Text("Loading...") })
//            }
//            
//            Spacer()
//        }
//        .padding()
        
        
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
    
    func fetchUploadedDocuments(id:String) {
        let storage = Storage.storage()
        let documentUUID = id
        let storageRef = storage.reference().child("health_records/\(documentUUID)")

        storageRef.listAll { result, error in
            if let error = error {
                print("Error fetching uploaded documents from Storage: \(error.localizedDescription)")
            } else {
                // Assign the list of StorageReferences to uploadedDocuments
                uploadedDocuments = result!.items
            }
        }
    }

    func viewDocument(documentRef: StorageReference) {
        documentRef.downloadURL { url, error in
            guard let downloadURL = url, error == nil else {
                print("Error getting document URL: \(error?.localizedDescription ?? "")")
                return
            }
            
            // Set isPDFLoading to true when starting to load PDF
            isPDFLoading = true

            // Perform asynchronous download using URLSession
            URLSession.shared.dataTask(with: downloadURL) { data, response, error in
                defer {
                    // Set isPDFLoading to false when PDF loading completes (whether successfully or with an error)
                    DispatchQueue.main.async {
                        isPDFLoading = false
                    }
                }
                guard let data = data, error == nil else {
                    print("Error downloading document: \(error?.localizedDescription ?? "")")
                    return
                }
                
                // Process downloaded data
                DispatchQueue.main.async {
                    if let pdfDocument = PDFDocument(data: data) {
                        // You can further customize the PDFView here (zoom, annotations etc.)
                        previewURL = downloadURL
                        isPreviewPresented = true
                    } else {
                        // Handle potential data error
                    }
                }
            }.resume()
        }
    }
}


struct PDFPreviewView: View {
    let pdfDocument: PDFDocument

    var body: some View {
        ZStack {
            PDFKitRepresentedView(pdfDocument: pdfDocument)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true // Enable auto scaling
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the view if needed
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .padding()
            TextField("Search", text: $searchText)
                .padding()
            Button(action: {
                searchText = ""
            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//                    .padding(.trailing, 10)
                Text("Clear")
            }
            .padding()
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
    }
}


struct PatientDetails_Previews: PreviewProvider {
    static var previews: some View {
        let dummyPatient = PatientModel(
            id: "1",
            fullName: "Dummy Patient",
            email: "dummy@example.com",
            gender: "Male",
            mobileno: "1234567890",
            dob: Date(timeIntervalSince1970: 0), // Example date (Jan 1, 1970)
            address: "123 Medical Lane",
            pincode: "123456",
            emergencyContact: "9876543210",
            bloodGroup: "O+",
            profilephoto: "https://www.example.com/patient-profile.jpg" // Example image URL
        )
        
        let dummyAppointment = AppointmentModel(
            id: "1",
            date: "",
            doctorID: "1",
            patientID: "2",
            timeSlot: "", 
            isComplete: false,
            reason: "consultation"
        )
        
        PatientAndAppoinmentDetails(patient: dummyPatient, appointment: dummyAppointment)
    }
}


#Preview {
    PatientAndAppoinmentDetails(patient: dummyPatient, appointment: dummyAppointment)
}
