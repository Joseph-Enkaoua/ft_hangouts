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
            Text("\(contact.name as String)")
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)

            if let nickname = contact.nickname {
                HStack {
                    Text("Nickname:")
                    Spacer()
                    Text("\(nickname as String)")
                }
                Divider()
                    .background(Color.gray)
            }
            HStack {
                Text("Phone:")
                Spacer()
                Text("\(contact.phone as String)")
            }
            if let address = contact.address {
                Divider()
                    .background(Color.gray)
                HStack {
                    Text("Address:")
                    Spacer()
                    Text("\(address as String)")
                }
            }
            if let email = contact.email {
                Divider()
                    .background(Color.gray)
                HStack {
                    Text("Email:")
                    Spacer()
                    Text("\(email as String)")
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ContactDetailView(contact: Contact(name: "jnai", phone: "980843"))
    }
}
