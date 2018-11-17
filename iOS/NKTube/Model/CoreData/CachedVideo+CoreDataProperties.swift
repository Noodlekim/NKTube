//
//  CachedVideo+CoreDataProperties.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/29.
//  Copyright © 2016年 NoodleKim. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CachedVideo {

    @NSManaged var channelTitle: String?
    @NSManaged var definition: String?
    @NSManaged var downloadDate: Date?
    @NSManaged var duration: String?
    @NSManaged var embedHtml: String?
    @NSManaged var group: String?
    @NSManaged var license: String?
    @NSManaged var likeCount: String?
    @NSManaged var order: NSNumber?
    @NSManaged var path: String?
    @NSManaged var playedCount: NSNumber?
    @NSManaged var privacyStatus: String?
    @NSManaged var publicStatsViewable: NSNumber?
    @NSManaged var quality: String?
    @NSManaged var thumbDefault: String?
    @NSManaged var thumbHigh: String?
    @NSManaged var thumbMaxres: String?
    @NSManaged var thumbMedium: String?
    @NSManaged var thumbStandard: String?
    @NSManaged var title: String?
    @NSManaged var unLike: String?
    @NSManaged var videoDescription: String?
    @NSManaged var videoId: String?
    @NSManaged var videoQulity: NSNumber?
    @NSManaged var viewsCount: String?
    @NSManaged var videoData: Data?

}
