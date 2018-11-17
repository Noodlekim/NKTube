//
//  GroupTitle+CoreDataProperties.swift
//  NKTube
//
//  Created by NoodleKim on 2016/03/11.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GroupTitle {

    @NSManaged var title: String?
    @NSManaged var order: NSNumber?
    @NSManaged var editable: NSNumber?

}
