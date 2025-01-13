//
//  dbHelper.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 07.01.2025.
//

import Foundation

let appDocumentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

public let part1DbPath = dbPath

var dbPath: String? {
    return appDocumentsDirectory?.appendingPathComponent("hangouts.sqlite").relativePath
}

func destroyDatabase() {
    guard let path = dbPath else { return }
    do {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    } catch {
        print("Could not destroy Database file.")
    }
}

func createDatabase() -> SQLiteDatabase {
    do {
        return try SQLiteDatabase.open(path: dbPath ?? "")
    } catch let error as SQLiteError {   // Type-cast error to SQLiteError
        switch error {
        case .OpenDatabase(let message):
            print("Error opening database: \(message)")
        case .Prepare(let message):
            print("Error preparing statement: \(message)")
        case .Step(let message):
            print("Error stepping through statement: \(message)")
        case .Bind(let message):
            print("Error binding parameters: \(message)")
        }
    } catch {
        print("Unknown error: \(error)")
    }
    exit(1)
}

func createTable(db: SQLiteDatabase) {
    do {
        try db.createTable(table: Contact.self)
    } catch let error as SQLiteError {   // Type-cast error to SQLiteError
        switch error {
        case .Prepare(let message):
            print("Error preparing statement: \(message)")
        case .Step(let message):
            print("Error stepping through statement: \(message)")
        case .Bind(let message):
            print("Error binding parameters: \(message)")
        default :
            print("Unexpected error: \(error)")
        }
    } catch {
        print("Unknown error: \(error)")
        exit(1)
    }
}

func insertContact(db: SQLiteDatabase, contact: Contact) -> Contact? {
    do {
        return try db.insertContact(contact: contact)
    } catch let error as SQLiteError {
        switch error {
        case .Bind(let message):
            print("Bind error: \(message)")
        case .Step(let message):
            print("Step error: \(message)")
        default:
            print("Unexpected error: \(error)")
        }
    } catch {
        print("Unknown error: \(error)")
    }
    return nil
}

func updateContact(db: SQLiteDatabase, contact: Contact) {
    do {
        try db.updateContact(contact: contact)
    } catch let error as SQLiteError {
        switch error {
        case .Bind(message: let message):
            print("Bind error: \(message)")
        case .Step(message: let message):
            print("Step error: \(message)")
        default:
            print("Unexpected error: \(error)")
        }
    } catch {
        print("Unknown error: \(error)")
    }
}

func selectContacts(db: SQLiteDatabase, id: Int) throws -> Contact? {
    let contact = try! db.readContact(id: Int32(id))
    return contact
}

func selectAllContacts(db: SQLiteDatabase) throws -> [Contact] {
    let contacts = try! db.readAllContacts()
    return contacts
}
