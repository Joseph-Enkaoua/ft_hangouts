//
//  contactForm.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 12.01.2025.
//

import SwiftUI

struct ContactFormView: View{
    let contact: Contact?
    
    @State private var navigationPath = NavigationPath()
    @State private var id: Int? = nil
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var nickname: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var message: String = ""
    @State private var savedContact: Contact? = nil

    init(contact: Contact? = nil) {
        self.contact = contact
    }
    
    var body: some View {
        NavigationStack {
            Text(id == nil ? "Add New Contact" : "Update Contact")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(alignment: .center)
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Group {
                    TextField("Name (required)", text: $name)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

                    TextField("Nickname", text: $nickname)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    TextField("Phone (required)", text: $phone)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    TextField("Address", text: $address)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                Button(action: submitForm) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .shadow(color: .purple.opacity(0.4), radius: 5, x: 0, y: 3)
                }
                .disabled(name.isEmpty || phone.isEmpty)
                .opacity(name.isEmpty || phone.isEmpty ? 0.5 : 1.0)
                
                if !message.isEmpty {
                    Text(message)
                        .font(.body)
                        .foregroundColor(message.contains("Success") ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                if let savedContact = savedContact {
                    NavigationLink(destination: ContactDetailView(contact: savedContact)) {
                        EmptyView()
                    }
                }
}
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            //        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
            .padding()
        }

    }
    
    private func loadContactDetails(contact: Contact) {
        id = contact.id
        name = contact.name as String
        nickname = (contact.nickname ?? "") as String
        email = (contact.email ?? "") as String
        phone = contact.phone as String
        address = (contact.address ?? "") as String
    }
    
    private func submitForm() {
        validateForm()
        
        var updatedContact = Contact(
            id: id,
            name: name,
            nickname: nickname.isEmpty ? nil : nickname,
            email: email.isEmpty ? nil : email,
            phone: phone,
            address: address.isEmpty ? nil : address
        )
        
        do {
            if let contactId = id {
                updatedContact.id = contactId
                try db.updateContact(contact: updatedContact)
            } else {
                guard let newContact = insertContact(db: db, contact: updatedContact) else {
                    message = "Failed to insert contact."
                    return
                }
                updatedContact = newContact
            }
            savedContact = updatedContact
        } catch {
            message = "Failed to save contact: \(error)"
        }
    }
    
    private func validateForm() {
        guard !name.isEmpty, !phone.isEmpty else {
            message = "Name and phone are required."
            return
        }
        guard name.count <= 50 , nickname.count <= 50 else {
            message = "Name and Nickname must be less than 50 characters."
            return
        }
        guard email.count <= 50 else {
            message = "Email must be less than 50 characters."
            return
        }
        guard phone.count <= 15 else {
            message = "Phone must be less than 15 characters."
            return
        }
        guard address.count <= 150 else {
            message = "Address must be less than 150 characters."
            return
        }
    }
}

struct contactFormView_Previews: PreviewProvider {
    static var previews: some View {
        ContactFormView()
    }
}
