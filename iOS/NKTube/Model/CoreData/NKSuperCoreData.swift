//
//  NKSuperCoreData.swift
//  NKTube
//
//  Created by NoodleKim on 2016/02/07.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//

import UIKit
import CoreData

class NKSuperCoreData: NSObject {

    lazy var mainContext: NSManagedObjectContext? = {
        return NKCoreDataManager.sharedInstance.mainContext
    }()
}
