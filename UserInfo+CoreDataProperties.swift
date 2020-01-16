//
//  UserInfo+CoreDataProperties.swift
//  
//
//  Created by 楊星星（Ｒｏｏｎｅｙ） on 2019/7/16.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var username: String?
    @NSManaged public var userid: Int32
    @NSManaged public var gender: Int32
    @NSManaged public var email: String?
    @NSManaged public var nickname: String?

}
