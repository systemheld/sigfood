//
//  Menu+CoreDataProperties.swift
//  Sigfood
//
//  Created by Kett, Oliver on 30.11.15.
//  Copyright © 2015 Kett, Oliver. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Menu {

    @NSManaged var date: NSDate?
    @NSManaged var garnish: String?
    @NSManaged var image: NSData?
    @NSManaged var mainCourse: String?
    @NSManaged var priceEmployee: String?
    @NSManaged var priceGuest: String?
    @NSManaged var priceStudent: String?
    @NSManaged var score: NSNumber?
    @NSManaged var imageID: NSNumber?
    @NSManaged var commentRef: NSSet?

}
