//
//  Location+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Jack McCabe on 1/19/22.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pics: [NSSet]?

}

// MARK: Generated accessors for pics
extension Location {

    @objc(addPicsObject:)
    @NSManaged public func addToPics(_ value: Pictures)

    @objc(removePicsObject:)
    @NSManaged public func removeFromPics(_ value: Pictures)

    @objc(addPics:)
    @NSManaged public func addToPics(_ values: NSSet)

    @objc(removePics:)
    @NSManaged public func removeFromPics(_ values: NSSet)

}

extension Location : Identifiable {

}
