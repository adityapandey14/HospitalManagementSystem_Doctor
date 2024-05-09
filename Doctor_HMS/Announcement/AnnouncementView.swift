//
//  AnnouncementView.swift
//  Doctor_HMS
//
//  Created by Arnav on 07/05/24.
//

import Foundation
import SwiftUI
import Firebase
struct Announcement:Identifiable {
    let id: String
    let text: String
    let dateTime: Date
}

class AnnouncementsViewModel: ObservableObject {
    @Published var announcements: [Announcement] = []

    private var db = Firestore.firestore()

    init() {
        // Fetch announcements from Firebase when the view model is initialized
        fetchAnnouncements()
    }


    private func fetchAnnouncements() {
        db.collection("announcements")
            .order(by: "dateTime", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                self.announcements = documents.compactMap { document in
                    let data = document.data()
                    guard let text = data["text"] as? String,
                          let dateTime = data["dateTime"] as? Timestamp else {
                        return nil
                    }

                    return Announcement(id: document.documentID, text: text, dateTime: dateTime.dateValue())
                }
            }
    }
}

struct AnnouncementsView: View {
    @EnvironmentObject var viewModel: AnnouncementsViewModel
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        NavigationView {
            List(viewModel.announcements) { announcement in
                VStack(alignment: .leading) {
                    Text(announcement.text)
                        .font(.headline)
                    Text(dateFormatter.string(from: announcement.dateTime))
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationBarTitle("Announcements")
        }
    }
}
