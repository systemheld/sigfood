//
//  Comment+CoreDataProperties.swift
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

extension Comment {

    @NSManaged var nickname: String?
    @NSManaged var text: String?
    @NSManaged var timestamp: NSNumber?
    @NSManaged var menuRef: Menu?

}
