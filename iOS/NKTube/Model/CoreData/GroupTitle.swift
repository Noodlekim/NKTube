//
//  GroupTitle.swift
//  NKTube
//
//  Created by NoodleKim on 2016/03/11.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import Foundation
import CoreData


class GroupTitle: NSManagedObject {

    class func getNewEntity() -> GroupTitle? {
        
        if let mainContext = NKCoreDataManager.sharedInstance.mainContext {
            let entityDescription = NSEntityDescription.entity(forEntityName: "GroupTitle", in: mainContext)
            return GroupTitle(entity: entityDescription!, insertInto: mainContext)
        } else {
            return nil
        }
    }
    
    
    class func oldGroupTitle(_ title: String) -> GroupTitle? {
        
        if let mainContext = NKCoreDataManager.sharedInstance.mainContext {
            
            // Create Fetch Request
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupTitle")
            
            let predicate = NSPredicate(format: "title = %@", title)
            fetchRequest.predicate = predicate
            
            // Add Sort Descriptor
            let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            // Execute Fetch Request
            do {
                let result = try mainContext.fetch(fetchRequest)
                if result.count > 0 {
                    return result[0] as? GroupTitle
                } else {
                    return nil
                }
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    
    
    class func saveDataWithTitle(_ title: String) {
        
        if GroupTitle.oldGroupTitle(title) != nil {
            KLog("이미 저장된 데이터 있음.");
            return
        }
        
        if let groupTitleModel = GroupTitle.getNewEntity() {
            
            groupTitleModel.title = title
            groupTitleModel.order = 0
            groupTitleModel.editable = true
        }
    }

}
