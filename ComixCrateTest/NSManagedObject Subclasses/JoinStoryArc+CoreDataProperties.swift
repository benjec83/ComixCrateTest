//
//  JoinStoryArc+CoreDataProperties.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 9/29/23.
//
//

import Foundation
import CoreData


extension JoinStoryArc {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<JoinStoryArc> {
        return NSFetchRequest<JoinStoryArc>(entityName: "JoinStoryArc")
    }

    @NSManaged public var storyArcPart: Int16
    @NSManaged public var book: Books?
    @NSManaged public var storyArc: BookStoryArcs?

}

extension JoinStoryArc : Identifiable {

}
