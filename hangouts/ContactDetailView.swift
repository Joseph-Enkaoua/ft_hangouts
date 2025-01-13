//
//  ContactDetailView.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 09.01.2025.
//

import SwiftUI

struct ContactDetailView: View {
    let contact: Contact
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(contact.name as String)")
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            
            List {
                if let nickname = contact.nickname {
                    HStack {
                        Text("Nickname:")
                        Spacer()
                        Text("\(nickname as String)")
                    }
                }
                HStack {
                    Text("Phone:")
                    Spacer()
                    Text("\(contact.phone as String)")
                }
                if let address = contact.address {
                    HStack {
                        Text("Address:")
                        Spacer()
                        Text("\(address as String)")
                    }
                }
                if let email = contact.email {
                    HStack {
                        Text("Email:")
                        Spacer()
                        Text("\(email as String)")
                    }
                }
            }
            Spacer()
        }
    }
}

struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        @State var mockNavigationPath = NavigationPath()
        
        ContactDetailView(contact: Contact(name: "jnai", phone: "980843"), navigationPath: $mockNavigationPath)
    }
}
