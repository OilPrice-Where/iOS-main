//
//  Card+CoreDataProperties.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/07/31.
//  Copyright © 2022 sangwook park. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Card)
public class Card: NSManagedObject {
    @NSManaged public var identifier: String
    @NSManaged public var name: String?
    @NSManaged public var isLiter: Bool
    @NSManaged public var saleValue: Double
    @NSManaged public var applyBrands: [String]?
    @NSManaged public var insertDate: Date?
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }
}

extension Card : Identifiable {

}
