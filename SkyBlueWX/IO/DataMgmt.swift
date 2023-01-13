//
//  DataMgmt.swift
//  SkyBlueWX
//
//  Created by DeltaSierra Aeronautical on 12/17/22.
//

/// Database "airdata.db" populated from OurAirports.com. Thanks to the contributor community :)
import Foundation
import SQLite3


enum QueryReturnType {
    case airport
}

enum DataBaseHandlerError: Error {
    case missingDataBaseFile
    case sqlLoadError
}

typealias Airport = (id: Int, icao: String, name: String, city: String)
typealias AirportDict = [Int : Airport]

let airportTable = "airports"

struct DataBaseHandler {
    func openConnection() throws -> OpaquePointer? {
        var db : OpaquePointer?
        // Look for DB path and return if not found.
        guard let dbPath = Bundle.main.url(forResource: "airdata", withExtension: "db") else {throw DataBaseHandlerError.missingDataBaseFile}
        // Try to open DB and report result.
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
            return db
        } else {
            throw DataBaseHandlerError.sqlLoadError
        }
    }
    
    
    // Use <T> to indicate this is a generic data type, NOT a variable. T is a placeholder.
    // This is convenient when a return type could change (say, depending on the returnType parameter's value?)
    private func runQuery(query : String, returnType : QueryReturnType?) -> AirportDict? {
        
        func populateAirports() -> AirportDict {
            var resultingAirports : AirportDict = [:]
            while sqlite3_step(statement) == SQLITE_ROW {
                let airportRow = parseAirportRow()
                resultingAirports[airportRow.id] = airportRow
            }
            return resultingAirports
        }
        
        func parseAirportRow() -> Airport {
            let id = Int(sqlite3_column_int(statement, 0))
            let ident = sqlite3_column_text(statement, 12) != nil ? String(cString: sqlite3_column_text(statement, 12)!) : ""
            let name = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)!) : ""
            let city = sqlite3_column_text(statement, 10) != nil ? String(cString: sqlite3_column_text(statement, 10)!) : ""
            return (id: id, icao: ident, name: name, city: city)
        }
        
        func closeAsPass() {
            sqlite3_finalize(statement)
        }
        
        func closeAsFail() {
            print("Statement failed...")
            sqlite3_finalize(statement)
        }
        
        var statement : OpaquePointer?
        if sqlite3_prepare_v2(pointer, query, -1, &statement, nil) == SQLITE_OK {
            // Handle cases where no return is expected.
            guard let _ = returnType else {
                if sqlite3_step(statement) == SQLITE_DONE {closeAsPass()}
                else {closeAsFail()}
                return nil
            }
            // Determine which processing helper function is needed
            switch returnType! {
            case .airport : let results = populateAirports(); closeAsPass(); return results
            }
        } else {
            print("Statement did not compile...")
        }
        sqlite3_finalize(statement)
        return nil
    }
    
    func getAirports(searchTerm : String, onlyByIcao: Bool = false) -> AirportDict? {
        if searchTerm.count < 2 {return nil}
        let queryString : String
        if onlyByIcao {
            queryString = "SELECT * FROM \(airportTable) WHERE type != 'closed' AND gps_code IS NOT NULL AND ident LIKE '\(searchTerm)%'"
        } else {
            queryString = "SELECT * FROM \(airportTable) WHERE type != 'closed' AND gps_code IS NOT NULL AND (ident LIKE '\(searchTerm)%' OR gps_code LIKE '\(searchTerm)%' OR iata_code LIKE '\(searchTerm)%' OR municipality LIKE '\(searchTerm)%') LIMIT 100"
        }
        let airportOutput : AirportDict? = runQuery(query: queryString, returnType: .airport)
        return airportOutput
    }
    
    var pointer : OpaquePointer?
    
    
    
    init() {
        do {
            try self.pointer = openConnection()
        } catch DataBaseHandlerError.missingDataBaseFile {
            
        } catch DataBaseHandlerError.sqlLoadError {
            
        } catch {
            print("Error not handled...")
        }
    }
}
