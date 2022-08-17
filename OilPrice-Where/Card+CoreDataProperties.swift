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


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var name: String?
    @NSManaged public var isLiter: Bool
    @NSManaged public var saleValue: Double
    @NSManaged public var applyBrands: [String]?

}

extension Card : Identifiable {

}
