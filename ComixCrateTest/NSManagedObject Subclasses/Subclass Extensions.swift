//
//  Subclass Extensions.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 9/29/23.
//

import Foundation
import CoreData
import SwiftUI

extension Books {
    
    // Books Sorted by Title
    static var sortedByTitle:
    NSFetchRequest<Books> {
        let request = NSFetchRequest<Books>(entityName: "Books")
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Books.title,
                ascending: true)
        ]
        return request
    }
    
    // Books Sorted by Series and Issue Number
    static var sortedBySeriesIssueFetchRequest: NSFetchRequest<Books> {
        let request = NSFetchRequest<Books>(entityName: "Books")
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Books.bookSeries?.name,
                ascending: true),
            NSSortDescriptor(
                keyPath: \Books.issueNumber,
                ascending: true)
        ]
        return request
    }
}

extension BookStoryArcs {
    
    // Book Story Arcs sorted by Story Arc name
    static var sortedByNameFetchRequest: NSFetchRequest<BookStoryArcs> {
        let request = NSFetchRequest<BookStoryArcs>(entityName: "BookStoryArcs")
        request.sortDescriptors = [NSSortDescriptor(
            keyPath: \BookStoryArcs.name,
            ascending: true)
        ]
        return request
    }
}

extension JoinStoryArc {
    
    // Book Story Arc relationships sorted by Issue Number
    static var sortedByBookIssueNumberFetchRequest: NSFetchRequest<JoinStoryArc> {
        let request = NSFetchRequest<JoinStoryArc>(entityName: "JoinStoryArc")
        request.sortDescriptors = [NSSortDescriptor(
            keyPath: \JoinStoryArc.book?.issueNumber,
            ascending: true)
        ]
        return request
    }
}

extension BookSeries {
    
    // Book Series sorted by Series
    static var sortedBySeriesFetchRequest:
    NSFetchRequest<BookSeries> {
        let request = NSFetchRequest<BookSeries>(entityName: "BookSeries")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BookSeries.name, ascending: true)
        ]
        return request
    }
}

extension BookLocations {
    
    // Book Locations Sorted by Name
    static var sortedByName:
    NSFetchRequest<BookLocations> {
        let request = NSFetchRequest<BookLocations>(entityName: "BookLocations")
        request.sortDescriptors = [
        NSSortDescriptor(
            keyPath: \BookLocations.name,
            ascending: true)
        ]
        return request
    }
}


