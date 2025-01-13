//
//  hangoutsApp.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 03.01.2025.
//

import SwiftUI

public var contacts: [Contact] = []
public let db: SQLiteDatabase = createDatabase()

@main
struct hangoutsApp: App {
    init() {
        destroyDatabase() // remove on production!
        createTable(db: db)
    }
    var body: some Scene {
        WindowGroup {
            ContactListView()
        }
    }
}
