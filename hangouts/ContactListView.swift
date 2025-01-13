//
//  ContentView.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 03.01.2025.
//

import SwiftUI

struct ContactListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var contacts: [Contact] = []
    @State private var navigationPath = NavigationPath()

    init() {
        // Insert sample data
        let a1 = insertContact(db: db, contact: Contact(name: "Jonny", nickname: "nick", phone: "90767"))
        let a2 = insertContact(db: db, contact: Contact(name: "Olaf", phone: "444", address: "Couchirardrard"))
        let a3 = insertContact(db: db, contact: Contact(name: "Elon", email: "elon@example.com", phone: "12345", address: "Mars"))
        print(a1 ?? "r" , a2 ?? "r" , a3 ?? "r")
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // Main content
                List(contacts) { contact in
                    NavigationLink(value: contact) {
                        VStack(alignment: .leading) {
                            Text(contact.name as String)
                                .font(.headline)
                            if let nickname = contact.nickname {
                                Text("(\(nickname))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("Contacts")
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        loadContacts()
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: Contact.self) { contact in
                    ContactDetailView(contact: contact, navigationPath: $navigationPath)
                }

                // Floating Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(
                            destination: ContactFormView(),
                            label: {
                                Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.purple)
                                    .clipShape(Circle())
                                    .shadow(color: .gray.opacity(0.8), radius: 5, x: 0, y: 3)
                            }
                        )
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: loadContacts)
    }
        
    // Load contacts from the database
    private func loadContacts() {
        do {
            self.contacts = try selectAllContacts(db: db)
        } catch {
            print("Error loading contacts: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContactListView()
    }
}
