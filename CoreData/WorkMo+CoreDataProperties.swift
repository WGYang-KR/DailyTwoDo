//
//  WorkMo+CoreDataProperties.swift
//  
//
//  Created by WG Yang on 2022/04/18.
//
//

import Foundation
import CoreData


extension WorkMo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkMo> {
        return NSFetchRequest<WorkMo>(entityName: "Work")
    }

    @NSManaged public var order: Int16
    @NSManaged public var status: Int16
    @NSManaged public var title: String?
    @NSManaged public var day: DayMo?

}
