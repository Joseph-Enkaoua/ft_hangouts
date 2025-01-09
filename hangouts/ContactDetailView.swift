//
//  ContactDetailView.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 09.01.2025.
//

import SwiftUI

struct ContactDetailView: View {
    let contact: Contact

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Name: \(contact.name as String)")
                .font(.headline)
            if let nickname = contact.nickname {
                Text("Nickname: \(nickname as String)")
            }
            if let email = contact.email {
                Text("Email: \(email as String)")
            }
            Text("Phone: \(contact.phone as String)")
            if let address = contact.address {
                Text("Address: \(address as String)")
            }
            Spacer()
        }
        .padding()
        .navigationTitle(contact.name as String)
    }
}
