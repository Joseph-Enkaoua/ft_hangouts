//
//  hangoutsApp.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 03.01.2025.
//

import SwiftUI

public var contacts: [Contact] = []

@main
struct hangoutsApp: App {

    var body: some Scene {
        WindowGroup {
            ContactListView()
        }
    }
}
