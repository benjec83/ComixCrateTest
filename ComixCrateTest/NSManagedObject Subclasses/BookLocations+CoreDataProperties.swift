//
//  BookLocations+CoreDataProperties.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 9/29/23.
//
//

import Foundation
import CoreData


extension BookLocations {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookLocations> {
        return NSFetchRequest<BookLocations>(entityName: "BookLocations")
    }

    @NSManaged public var name: String?
    @NSManaged public var books: Books?
    @NSManaged public var publisher: NSSet?

}

// MARK: Generated accessors for publisher
extension BookLocations {

    @objc(addPublisherObject:)
    @NSManaged public func addToPublisher(_ value: Publishers)

    @objc(removePublisherObject:)
    @NSManaged public func removeFromPublisher(_ value: Publishers)

    @objc(addPublisher:)
    @NSManaged public func addToPublisher(_ values: NSSet)

    @objc(removePublisher:)
    @NSManaged public func removeFromPublisher(_ values: NSSet)

}

extension BookLocations : Identifiable {

}
