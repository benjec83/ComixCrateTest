//
//  BookStoryArcs+CoreDataProperties.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 9/29/23.
//
//

import Foundation
import CoreData


extension BookStoryArcs {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookStoryArcs> {
        return NSFetchRequest<BookStoryArcs>(entityName: "BookStoryArcs")
    }

    @NSManaged public var name: String?
    @NSManaged public var storyArcDescription: String?
    @NSManaged public var storyArcOrder: Int16
    @NSManaged public var joinStoryArc: NSSet?

}

// MARK: Generated accessors for joinStoryArc
extension BookStoryArcs {

    @objc(addJoinStoryArcObject:)
    @NSManaged public func addToJoinStoryArc(_ value: JoinStoryArc)

    @objc(removeJoinStoryArcObject:)
    @NSManaged public func removeFromJoinStoryArc(_ value: JoinStoryArc)

    @objc(addJoinStoryArc:)
    @NSManaged public func addToJoinStoryArc(_ values: NSSet)

    @objc(removeJoinStoryArc:)
    @NSManaged public func removeFromJoinStoryArc(_ values: NSSet)

}

extension BookStoryArcs : Identifiable {

}
