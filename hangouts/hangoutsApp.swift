//
//  hangoutsApp.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 03.01.2025.
//

import SwiftUI

@main
struct hangoutsApp: App {
    init() {
        let db = openDatabase()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

func openDatabase() -> OpaquePointer? {
  var db: OpaquePointer?
  guard let part1DbPath = part1DbPath else {
    print("part1DbPath is nil.")
    return nil
  }
  if sqlite3_open(part1DbPath, &db) == SQLITE_OK {
    print("Successfully opened connection to database at \(part1DbPath)")
    return db
  } else {
    print("Unable to open database.")
    PlaygroundPage.current.finishExecution()
  }
}

