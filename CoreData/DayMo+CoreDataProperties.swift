//
//  DayMo+CoreDataProperties.swift
//  
//
//  Created by WG Yang on 2022/04/18.
//
//

import Foundation
import CoreData


extension DayMo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayMo> {
        return NSFetchRequest<DayMo>(entityName: "Day")
    }

    @NSManaged public var date: Date?
    @NSManaged public var memo: String?
    @NSManaged public var works: NSSet?

}

// MARK: Generated accessors for works
extension DayMo {

    @objc(addWorksObject:)
    @NSManaged public func addToWorks(_ value: WorkMo)

    @objc(removeWorksObject:)
    @NSManaged public func removeFromWorks(_ value: WorkMo)

    @objc(addWorks:)
    @NSManaged public func addToWorks(_ values: NSSet)

    @objc(removeWorks:)
    @NSManaged public func removeFromWorks(_ values: NSSet)

}
