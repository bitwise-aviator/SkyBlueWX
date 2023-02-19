//
//  PersistenceController.swift
//  SkyBlueWX
//
//  Created by Daniel Sanchez on 2/19/23.
//

import Foundation
import CoreData
import SwiftUI

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "DataStorage")
        container.loadPersistentStores { _, error in
            //
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        print(NSPersistentContainer.defaultDirectoryURL())
    }
    func updateStoredAirports(code: String, atStart: Bool) -> Bool {
        let fetchRequest: NSFetchRequest<StoredAirport>
        fetchRequest = StoredAirport.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "code = %@", code
        )
        let fetchResult = try? container.viewContext.fetch(fetchRequest)
        if let fetchResult = fetchResult {
            print(fetchResult)
            if !fetchResult.isEmpty && fetchResult.count == 1 {
                print("Found record for \(code), updating...")
                let existingCode = fetchResult[0]
                print("\(existingCode.atStart) -> \(atStart)")
                existingCode.setValue(atStart, forKey: "atStart")
            } else if !fetchResult.isEmpty {
                print("Several entries for \(code) found...")
            } else {
                print("No record found for \(code), creating...")
                let newRecord = StoredAirport(context: container.viewContext)
                newRecord.code = code
                newRecord.atStart = atStart
            }
        }
        let saveOk = save()
        print("\(saveOk ? "Saved OK!" : "Did not save...")")
        return saveOk
    }
    func getStartupAirports() -> Set<String> {
        let fetchRequest: NSFetchRequest<StoredAirport>
        fetchRequest = StoredAirport.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "atStart = YES")
        let fetchResults = try? container.viewContext.fetch(fetchRequest)
        guard let fetchResults = fetchResults else { return [] }
        return Set(fetchResults.compactMap { $0.code })
    }
    func save() -> Bool {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
                return true
            } catch {
                return false
            }
        }
        return true
    }
}
