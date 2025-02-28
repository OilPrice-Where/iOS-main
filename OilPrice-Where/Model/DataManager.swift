//
//  DataManager.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/12.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Combine
import CoreData
import Foundation


final class DataManager {
    
    static let shared = DataManager()
    private init() {}
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.containerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                assertionFailure("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension DataManager {
    private enum Constants {
        static let containerName = "DataModel"
        static let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
    }
    
    func fetch<T>(request: NSFetchRequest<T>) throws -> [T] {
        do {
            return try mainContext.fetch(request)
        } catch {
            throw error
        }
    }
    
    func delete<T: NSManagedObject>(value: T?) {
        guard let managedObject = value else {
            return
        }
        
        mainContext.delete(managedObject)
        saveContext()
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}
