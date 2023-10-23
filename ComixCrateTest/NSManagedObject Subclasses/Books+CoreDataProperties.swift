//
//  Books+CoreDataProperties.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/11/23.
//
//

import Foundation
import CoreData


extension Books {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Books> {
        return NSFetchRequest<Books>(entityName: "Books")
    }

    @NSManaged public var cachedThumbnailData: Data?
    @NSManaged public var communityRating: Double
    @NSManaged public var condition: String?
    @NSManaged public var coverDate: Date?
    @NSManaged public var coverPrice: Double
    @NSManaged public var currentValue: Double
    @NSManaged public var dateAdded: Date?
    @NSManaged public var dateModified: Date?
    @NSManaged public var downloaded: Bool
    @NSManaged public var fileName: String?
    @NSManaged public var filePath: String?
    @NSManaged public var gradedBy: String?
    @NSManaged public var gradeValue: Double
    @NSManaged public var id: UUID?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var issueNumber: Int16
    @NSManaged public var language: String?
    @NSManaged public var notes: String?
    @NSManaged public var pageCount: Int16
    @NSManaged public var personalRating: Double
    @NSManaged public var purchaseDate: Date?
    @NSManaged public var purchaseFrom: String?
    @NSManaged public var purchasePrice: Double
    @NSManaged public var read: Double
    @NSManaged public var releaseDate: Date?
    @NSManaged public var summary: String?
    @NSManaged public var thumbnailPath: String?
    @NSManaged public var title: String?
    @NSManaged public var volumeNumber: Int16
    @NSManaged public var volumeYear: Int16
    @NSManaged public var web: String?
    @NSManaged public var bookIsRead: Bool
    @NSManaged public var bookCharacters: NSSet?
    @NSManaged public var bookCreatorRoles: NSSet?
    @NSManaged public var bookEvents: NSSet?
    @NSManaged public var bookLocations: NSSet?
    @NSManaged public var bookSeries: BookSeries?
    @NSManaged public var bookTeams: NSSet?
    @NSManaged public var eras: NSSet?
    @NSManaged public var formats: NSSet?
    @NSManaged public var imprints: Imprints?
    @NSManaged public var joinStoryArcs: NSSet?
    @NSManaged public var publishers: Publishers?
    @NSManaged public var readingLists: NSSet?

}

// MARK: Generated accessors for bookCharacters
extension Books {

    @objc(addBookCharactersObject:)
    @NSManaged public func addToBookCharacters(_ value: BookCharcters)

    @objc(removeBookCharactersObject:)
    @NSManaged public func removeFromBookCharacters(_ value: BookCharcters)

    @objc(addBookCharacters:)
    @NSManaged public func addToBookCharacters(_ values: NSSet)

    @objc(removeBookCharacters:)
    @NSManaged public func removeFromBookCharacters(_ values: NSSet)

}

// MARK: Generated accessors for bookCreatorRoles
extension Books {

    @objc(addBookCreatorRolesObject:)
    @NSManaged public func addToBookCreatorRoles(_ value: BookCreators)

    @objc(removeBookCreatorRolesObject:)
    @NSManaged public func removeFromBookCreatorRoles(_ value: BookCreators)

    @objc(addBookCreatorRoles:)
    @NSManaged public func addToBookCreatorRoles(_ values: NSSet)

    @objc(removeBookCreatorRoles:)
    @NSManaged public func removeFromBookCreatorRoles(_ values: NSSet)

}

// MARK: Generated accessors for bookEvents
extension Books {

    @objc(addBookEventsObject:)
    @NSManaged public func addToBookEvents(_ value: BookEvents)

    @objc(removeBookEventsObject:)
    @NSManaged public func removeFromBookEvents(_ value: BookEvents)

    @objc(addBookEvents:)
    @NSManaged public func addToBookEvents(_ values: NSSet)

    @objc(removeBookEvents:)
    @NSManaged public func removeFromBookEvents(_ values: NSSet)

}

// MARK: Generated accessors for bookLocations
extension Books {

    @objc(addBookLocationsObject:)
    @NSManaged public func addToBookLocations(_ value: BookLocations)

    @objc(removeBookLocationsObject:)
    @NSManaged public func removeFromBookLocations(_ value: BookLocations)

    @objc(addBookLocations:)
    @NSManaged public func addToBookLocations(_ values: NSSet)

    @objc(removeBookLocations:)
    @NSManaged public func removeFromBookLocations(_ values: NSSet)

}

// MARK: Generated accessors for bookTeams
extension Books {

    @objc(addBookTeamsObject:)
    @NSManaged public func addToBookTeams(_ value: BookTeams)

    @objc(removeBookTeamsObject:)
    @NSManaged public func removeFromBookTeams(_ value: BookTeams)

    @objc(addBookTeams:)
    @NSManaged public func addToBookTeams(_ values: NSSet)

    @objc(removeBookTeams:)
    @NSManaged public func removeFromBookTeams(_ values: NSSet)

}

// MARK: Generated accessors for eras
extension Books {

    @objc(addErasObject:)
    @NSManaged public func addToEras(_ value: Eras)

    @objc(removeErasObject:)
    @NSManaged public func removeFromEras(_ value: Eras)

    @objc(addEras:)
    @NSManaged public func addToEras(_ values: NSSet)

    @objc(removeEras:)
    @NSManaged public func removeFromEras(_ values: NSSet)

}

// MARK: Generated accessors for formats
extension Books {

    @objc(addFormatsObject:)
    @NSManaged public func addToFormats(_ value: Formats)

    @objc(removeFormatsObject:)
    @NSManaged public func removeFromFormats(_ value: Formats)

    @objc(addFormats:)
    @NSManaged public func addToFormats(_ values: NSSet)

    @objc(removeFormats:)
    @NSManaged public func removeFromFormats(_ values: NSSet)

}

// MARK: Generated accessors for joinStoryArcs
extension Books {

    @objc(addJoinStoryArcsObject:)
    @NSManaged public func addToJoinStoryArcs(_ value: JoinStoryArc)

    @objc(removeJoinStoryArcsObject:)
    @NSManaged public func removeFromJoinStoryArcs(_ value: JoinStoryArc)

    @objc(addJoinStoryArcs:)
    @NSManaged public func addToJoinStoryArcs(_ values: NSSet)

    @objc(removeJoinStoryArcs:)
    @NSManaged public func removeFromJoinStoryArcs(_ values: NSSet)

}

// MARK: Generated accessors for readingLists
extension Books {

    @objc(addReadingListsObject:)
    @NSManaged public func addToReadingLists(_ value: ReadingLists)

    @objc(removeReadingListsObject:)
    @NSManaged public func removeFromReadingLists(_ value: ReadingLists)

    @objc(addReadingLists:)
    @NSManaged public func addToReadingLists(_ values: NSSet)

    @objc(removeReadingLists:)
    @NSManaged public func removeFromReadingLists(_ values: NSSet)

}

extension Books : Identifiable {

}
