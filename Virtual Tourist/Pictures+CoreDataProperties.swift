//
//  Pictures+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Jack McCabe on 1/19/22.
//
//

import Foundation
import CoreData


extension Pictures {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pictures> {
        return NSFetchRequest<Pictures>(entityName: "Pictures")
    }
    
    //should I change to NSData?
    @NSManaged public var picture: NSObject?
    @NSManaged public var loc: Location?

}

extension Pictures : Identifiable {

}
