//
//  ContentView.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 03.01.2025.
//

import SwiftUI

struct ContactListView: View {
    @State private var contacts: [Contact] = []
    private let db: SQLiteDatabase

    init() {
        // Initialize the database
        destroyDatabase() // remove on production!
        self.db = createDatabase()
        createTable(db: self.db)
        
        // Insert sample data
        insertContact(db: self.db, contact: Contact(name: "Jonny", nickname: "nick", phone: "90767"))
        insertContact(db: self.db, contact: Contact(name: "Olaf", phone: "444", address: "Couchirardrard"))
        insertContact(db: self.db, contact: Contact(name: "Elon", email: "elon@example.com", phone: "12345", address: "Mars"))
    }

    var body: some View {
        NavigationView {
            List(contacts, id: \.id) { contact in
                NavigationLink(
                    destination: ContactDetailView(contact: contact),
                    label: {
                        Text(contact.name as String)
                        Text(contact.nickname == nil ? "" : " (\(contact.nickname!))")
                    }
                )
            }
            .navigationTitle("Contacts")
            .onAppear(perform: loadContacts)
            .listStyle(.plain)
        }
    }
        
    // Load contacts from the database
    private func loadContacts() {
        do {
            self.contacts = try selectAllContacts(db: self.db)
        } catch {
            print("Error loading contacts: \(error)")
        }
    }
}
