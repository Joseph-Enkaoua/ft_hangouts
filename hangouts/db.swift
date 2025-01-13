//
//  db.swift
//  hangouts
//
//  Created by Joseph Enkaoua on 07.01.2025.
//

import Foundation
import SQLite3

// Enum to make errors clear
public enum SQLiteError: Error {
      case OpenDatabase(message: String)
      case Prepare(message: String)
      case Step(message: String)
      case Bind(message: String)
}

// The contact struct
public struct Contact: Identifiable {
    public var id: Int?
    var name: NSString
    var nickname: NSString?
    var email: NSString?
    var phone: NSString
    var address: NSString?
    
    init(
        id: Int? = nil,
        name: String,
        nickname: String? = nil,
        email: String? = nil,
        phone: String,
        address: String? = nil
    ) {
        self.id = id
        self.name = name as NSString
        self.nickname = nickname as NSString?
        self.email = email as NSString?
        self.phone = phone as NSString
        self.address = address as NSString?
    }
}

// Database class
public class SQLiteDatabase {
    private let dbPointer: OpaquePointer?
    private init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    deinit {
        sqlite3_close(dbPointer)
    }

    static  func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer?
        if sqlite3_open(path, &db) == SQLITE_OK {
            print("all good here")
            return SQLiteDatabase(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String(cString: errorPointer)
                throw SQLiteError.OpenDatabase(message: message)
            } else {
                throw SQLiteError
                    .OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }

    fileprivate var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
}

// Prepare SQL statement
extension SQLiteDatabase {
    func prepareStatement(sqlQueryString: String) throws -> OpaquePointer? {
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sqlQueryString, -1, &statement, nil)
                == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return statement
    }
}

protocol SQLTable {
    static var createStatement: String { get }
}

// Create table statement
extension Contact: SQLTable {
    static var createStatement: String {
        return """
            CREATE TABLE IF NOT EXISTS Contact (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL CHECK (LENGTH(name) <= 50),
            nickname TEXT CHECK (LENGTH(nickname) <= 50),
            email TEXT CHECK (LENGTH(email) <= 50),
            phone TEXT NOT NULL CHECK (LENGTH(phone) <= 15),
            address TEXT CHECK (LENGTH(address) <= 150)
        );
        """
    }
    static var insertStatement: String {
        return """
            INSERT INTO Contact (name, nickname, email, phone, address) VALUES (?, ?, ?, ?, ?
        );
        """
    }
    static var selectStatement: String {
        return "SELECT * FROM Contact WHERE id = ?;"
    }
    static var selectAllStatement: String {
        return "SELECT * FROM Contact ORDER BY name;"
    }
    static var updateStatement: String {
        return "UPDATE Contact SET name = ?, nickname = ?, email = ?, phone = ?, address = ? WHERE id = ?;"
    }
}

// Create table
extension SQLiteDatabase {
    func createTable(table: SQLTable.Type) throws {
        let createTableStatement = try prepareStatement(sqlQueryString: table.createStatement)
        defer {
            sqlite3_finalize(createTableStatement)
        }

        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        print("\(table) table created")
    }
}

// Insert contact
extension SQLiteDatabase {
    func insertContact(contact: Contact) throws -> Contact? {
        let insertStatement = try prepareStatement(sqlQueryString: Contact.insertStatement)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        // Bind required fields
        guard sqlite3_bind_text(insertStatement, 1, contact.name.utf8String, -1, nil) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(insertStatement))
            throw SQLiteError.Bind(message: "Bind failed for name: \(errorMessage)")
        }
        
        guard sqlite3_bind_text(insertStatement, 4, contact.phone.utf8String, -1, nil) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(insertStatement))
            throw SQLiteError.Bind(message: "Bind failed for phone: \(errorMessage)")
        }

        // Bind optional fields
        let nicknameResult = contact.nickname.map {
            sqlite3_bind_text(insertStatement, 2, $0.utf8String, -1, nil)
        } ?? sqlite3_bind_null(insertStatement, 2)
        
        let emailResult = contact.email.map {
            sqlite3_bind_text(insertStatement, 3, $0.utf8String, -1, nil)
        } ?? sqlite3_bind_null(insertStatement, 3)
        
        let addressResult = contact.address.map {
            sqlite3_bind_text(insertStatement, 5, $0.utf8String, -1, nil)
        } ?? sqlite3_bind_null(insertStatement, 5)
        
        guard nicknameResult == SQLITE_OK, emailResult == SQLITE_OK, addressResult == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(insertStatement))
            throw SQLiteError.Bind(message: "Bind failed for optional fields: \(errorMessage)")
        }
        
        // Execute the statement
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            let errorMessage = String(cString: sqlite3_errmsg(insertStatement))
            throw SQLiteError.Step(message: "Execution failed: \(errorMessage)")
        }
        
        print("Successfully inserted row.")
        
        // Retrieve the last inserted row ID
        let lastInsertRowId = sqlite3_last_insert_rowid(dbPointer)
        print("Successfully inserted row with ID: \(lastInsertRowId).")
        
        // Return the created Contact with the assigned ID
        return Contact(
            id: Int(lastInsertRowId),
            name: contact.name as String,
            nickname: contact.nickname as? String,
            email: contact.email as? String,
            phone: contact.phone as String,
            address: contact.address as? String
        )
    }
}

// Update a contact
extension SQLiteDatabase {
    func updateContact(contact: Contact) throws {
        guard let updateStatement = try? prepareStatement(sqlQueryString: Contact.updateStatement) else {
            throw SQLiteError.Prepare(message: "Failed to prepare query")
        }
        defer {
            sqlite3_finalize(updateStatement)
        }
        
        // Bind required fields
        guard let contactId = contact.id else {
            throw SQLiteError.Bind(message: "Contact ID is nil")
        }
        guard sqlite3_bind_int(updateStatement, 6, Int32(contactId)) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(updateStatement))
            throw SQLiteError.Bind(message: "Bind failed for name: \(errorMessage)")
        }

        guard sqlite3_bind_text(updateStatement, 1, contact.name.utf8String, -1, nil) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(updateStatement))
            throw SQLiteError.Bind(message: "Bind failed for name: \(errorMessage)")
        }
        
        guard sqlite3_bind_text(updateStatement, 4, contact.phone.utf8String, -1, nil) == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(updateStatement))
            throw SQLiteError.Bind(message: "Bind failed for phone: \(errorMessage)")
        }

        // Bind optional fields
        let nicknameResult = contact.nickname.map {
            sqlite3_bind_text(updateStatement, 2, $0.utf8String, -1, nil)
        } ?? sqlite3_bind_null(updateStatement, 2)
        
        let emailResult = contact.email.map {
            sqlite3_bind_text(updateStatement, 3, $0.utf8String, -1, nil)
        } ?? sqlite3_bind_null(updateStatement, 3)
        
        let addressResult = contact.address.map {
            sqlite3_bind_text(updateStatement, 5, $0.utf8String, -1, nil)
        } ?? sqlite3_bind_null(updateStatement, 5)
        
        guard nicknameResult == SQLITE_OK, emailResult == SQLITE_OK, addressResult == SQLITE_OK else {
            let errorMessage = String(cString: sqlite3_errmsg(updateStatement))
            throw SQLiteError.Bind(message: "Bind failed for optional fields: \(errorMessage)")
        }

        // Execute the statement
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            let errorMessage = String(cString: sqlite3_errmsg(updateStatement))
            throw SQLiteError.Step(message: "Execution failed: \(errorMessage)")
        }

        print("Successfully updated row.")
    }
}

// Read a contact
extension SQLiteDatabase {
    func readContact(id: Int32) throws -> Contact? {
        guard let queryStatement = try? prepareStatement(sqlQueryString: Contact.selectStatement) else {
            throw SQLiteError.Prepare(message: "Failed to prepare query")
        }
        defer {
            sqlite3_finalize(queryStatement)
        }

        // Bind the ID to the query
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            throw SQLiteError.Bind(message: "Failed to bind ID")
        }

        // Execute the query
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil // No data found
        }

        // Map the columns to the Contact struct
        let id = sqlite3_column_int(queryStatement, 0) // Column 0: id
        let name = String(cString: sqlite3_column_text(queryStatement, 1)) // Column 1: name
        let nickname = sqlite3_column_text(queryStatement, 2) != nil ?
            String(cString: sqlite3_column_text(queryStatement, 2)) : nil // Column 2: nickname
        let email = sqlite3_column_text(queryStatement, 3) != nil ?
            String(cString: sqlite3_column_text(queryStatement, 3)) : nil // Column 3: email
        let phone = String(cString: sqlite3_column_text(queryStatement, 4)) // Column 4: phone
        let address = sqlite3_column_text(queryStatement, 5) != nil ?
            String(cString: sqlite3_column_text(queryStatement, 5)) : nil // Column 5: address

        // Create and return a Contact instance
        let contact = Contact(
            id: Int(id),
            name: name as String,
            nickname: nickname as String?,
            email: email as String?,
            phone: phone as String,
            address: address as String?
        )
        return contact
    }
}

// Read all contacts
extension SQLiteDatabase {
    func readAllContacts() throws -> [Contact] {
        guard let queryStatement = try? prepareStatement(sqlQueryString: Contact.selectAllStatement) else {
            throw SQLiteError.Prepare(message: "Failed to prepare query")
        }
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        var contacts: [Contact] = []
        
        // Execute the query
        while (sqlite3_step(queryStatement) == SQLITE_ROW) {
            // Map the columns to the Contact struct
            let id = sqlite3_column_int(queryStatement, 0) // Column 0: id
            let name = String(cString: sqlite3_column_text(queryStatement, 1)) // Column 1: name
            let nickname = sqlite3_column_text(queryStatement, 2) != nil ?
                String(cString: sqlite3_column_text(queryStatement, 2)) : nil // Column 2: nickname
            let email = sqlite3_column_text(queryStatement, 3) != nil ?
                String(cString: sqlite3_column_text(queryStatement, 3)) : nil // Column 3: email
            let phone = String(cString: sqlite3_column_text(queryStatement, 4)) // Column 4: phone
            let address = sqlite3_column_text(queryStatement, 5) != nil ?
                String(cString: sqlite3_column_text(queryStatement, 5)) : nil // Column 5: address
            
            // Create and return a Contact instance
            let contact = Contact(
                id: Int(id),
                name: name as String,
                nickname: nickname as String?,
                email: email as String?,
                phone: phone as String,
                address: address as String?
            )
            
            contacts.append(contact)
        }
        return contacts
    }
}
