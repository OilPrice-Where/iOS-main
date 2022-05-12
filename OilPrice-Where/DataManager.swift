//
//  DataManager.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/12.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import CoreData
import RxSwift

class DataManager {
    static let shared = DataManager()
    private init() {}
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var stationListIsNotEmpty = PublishSubject<Bool>()
    var stationList = [Station]() { didSet { stationListIsNotEmpty.onNext(!stationList.isEmpty) } }
//    var cardList = [Card]()
    
    func fetchData() {
        let stationRequest: NSFetchRequest<Station> = Station.fetchRequest()
//        let cardRequest: NSFetchRequest<Card> = Card.fetchRequest()
        
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        stationRequest.sortDescriptors = [sortByDateDesc]
        //cardRequest.sortDescriptors = [sortByDateDesc]
        
        do {
            stationList = try mainContext.fetch(stationRequest)
            //cardList = try mainContext.fetch(cardRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addNew(staion: GasStation?) {
        let newStation = Station(context: mainContext)
        newStation.name = staion?.name
        newStation.brand = staion?.brand
        newStation.oilType = DefaultData.shared.oilSubject.value
        newStation.price = Double(staion?.price ?? 0)
        newStation.katecX = staion?.katecX ?? .zero
        newStation.katecY = staion?.katecY ?? .zero
        newStation.insertDate = Date()
        
        stationList.insert(newStation, at: 0)
        
        saveContext()
    }
    
    func addNew(card: Void) {
        
        saveContext()
    }
    
    func delete(station: Station?) {
        guard let station = station else {
            return
        }
        
        mainContext.delete(station)
        
        saveContext()
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
