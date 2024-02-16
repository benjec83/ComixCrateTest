//
//  Extensions.swift
//  ComixCrateTest
//
//  Created by Ben Carney on 10/11/23.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    static var preview: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel.mergedModel(from: nil)!)
        
        do {
            try coordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                               configurationName: nil,
                                               at: nil,
                                               options: nil)
        } catch {
            fatalError("Unable to load persistent store")
        }
        
        context.persistentStoreCoordinator = coordinator
        
        // Add sample data for BookSeries
        let series1 = BookSeries(context: context)
        series1.name = "Marvel Adventures"
        series1.dateStarted = Date().addingTimeInterval(-1892160000) // 60 years ago
        series1.isFavorite = true
        series1.dateFinished = Date().addingTimeInterval(-946944000) // 30 years ago
        series1.seriesDescription = "A series of adventures featuring Marvel superheroes."
        
        let series2 = BookSeries(context: context)
        series2.name = "Dark Tales"
        series2.dateStarted = Date().addingTimeInterval(-1135296000) // 36 years ago
        series2.isFavorite = false
        series2.dateFinished = Date().addingTimeInterval(-631584000) // 20 years ago
        series2.seriesDescription = "A series of dark and mysterious tales."
        
        let series3 = BookSeries(context: context)
        series3.name = "Invincible Iron Man"
        series3.dateStarted = Date().addingTimeInterval(-1135297000) // 36 years ago
        series3.isFavorite = false
        series3.dateFinished = Date().addingTimeInterval(-631586000) // 20 years ago
        series3.seriesDescription = "The return of everyone's favorite tech billionaire."
        
        let series4 = BookSeries(context: context)
        series4.name = "Knights of Asgard"
        series4.dateStarted = Date().addingTimeInterval(-1135296000) // 36 years ago
        series4.isFavorite = false
        series4.dateFinished = Date().addingTimeInterval(-631584000) // 20 years ago
        series4.seriesDescription = "Tales from the valent kingdom of Asgard."
        
        // Add sample data for Books and set up the relationship with BookSeries
        let sampleBook1 = Books(context: context)
       sampleBook1.title = "The Adventures of Captain Marvel"
       sampleBook1.issueNumber = 1
       sampleBook1.pageCount = 120
       sampleBook1.personalRating = 4.5
       sampleBook1.read = 100
       sampleBook1.releaseDate = Date() // Today's date for the sake of the example
       sampleBook1.summary = "A thrilling adventure of Captain Marvel saving the world."
       sampleBook1.volumeYear = 2021
       sampleBook1.bookIsRead = true
       sampleBook1.bookSeries = series1
        
        let sampleBook2 = Books(context: context)
        sampleBook2.title = "The Dark Tales of Gotham"
        sampleBook2.issueNumber = 5
        sampleBook2.pageCount = 150
        sampleBook2.personalRating = 4.0
        sampleBook2.read = 50
        sampleBook2.releaseDate = Date().addingTimeInterval(-31536000) // 1 year ago
        sampleBook2.summary = "Dark tales from the streets of Gotham."
        sampleBook2.volumeYear = 2020
        sampleBook2.bookIsRead = false
        sampleBook2.bookSeries = series2
        
        let sampleBook3 = Books(context: context)
        sampleBook3.title = "The Return of Thor"
        sampleBook3.issueNumber = 10
        sampleBook3.pageCount = 100
        sampleBook3.personalRating = 5.0
        sampleBook3.read = 80
        sampleBook3.releaseDate = Date().addingTimeInterval(-63072000) // 2 years ago
        sampleBook3.summary = "Thor returns to Asgard to reclaim his throne."
        sampleBook3.volumeYear = 2019
        sampleBook3.bookIsRead = true
        sampleBook3.bookSeries = series4
        
        let sampleBook4 = Books(context: context)
        sampleBook4.title = "The Joker's Last Laugh"
        sampleBook4.issueNumber = 15
        sampleBook4.pageCount = 140
        sampleBook4.personalRating = 3.5
        sampleBook4.read = 20
        sampleBook4.releaseDate = Date().addingTimeInterval(-94608000) // 3 years ago
        sampleBook4.summary = "The Joker's final plan to take down Batman."
        sampleBook4.volumeYear = 2018
        sampleBook4.bookIsRead = false
        sampleBook4.bookSeries = series2
        
        let sampleBook5 = Books(context: context)
        sampleBook5.title = "Iron Man: Rise of the Machines"
        sampleBook5.issueNumber = 20
        sampleBook5.pageCount = 130
        sampleBook5.personalRating = 4.7
        sampleBook5.read = 60
        sampleBook5.releaseDate = Date().addingTimeInterval(-126144000) // 4 years ago
        sampleBook5.summary = "Tony Stark faces a new technological threat."
        sampleBook5.volumeYear = 2017
        sampleBook5.bookIsRead = true
        sampleBook5.bookSeries = series3
        
        let sampleBook6 = Books(context: context)
        sampleBook6.title = "The Mystery of Arkham"
        sampleBook6.issueNumber = 25
        sampleBook6.pageCount = 110
        sampleBook6.personalRating = 3.8
        sampleBook6.read = 40
        sampleBook6.releaseDate = Date().addingTimeInterval(-157680000) // 5 years ago
        sampleBook6.summary = "A deep dive into the secrets of Arkham Asylum."
        sampleBook6.volumeYear = 2016
        sampleBook6.bookIsRead = false
        sampleBook6.bookSeries = series2
        
        // Add sample data for BookStoryArcs
        let sampleStoryArc1 = BookStoryArcs(context: context)
        sampleStoryArc1.name = "Sample Story Arc 1"
        
        let sampleStoryArc2 = BookStoryArcs(context: context)
        sampleStoryArc2.name = "Sample Story Arc 2"
        
        // Add sample data for JoinStoryArc to associate Books with BookStoryArcs
        let joinStoryArc1 = JoinStoryArc(context: context)
        joinStoryArc1.storyArcPart = 1
        joinStoryArc1.book = sampleBook1
        joinStoryArc1.storyArc = sampleStoryArc1
        
        let joinStoryArc2 = JoinStoryArc(context: context)
        joinStoryArc2.storyArcPart = 2
        joinStoryArc2.book = sampleBook2
        joinStoryArc2.storyArc = sampleStoryArc1
        
        do {
            try context.save()
        } catch {
            fatalError("Failed to save sample data")
        }
        
        return context
    }
}

extension NSManagedObjectContext {
    func populateSampleData() {
        let sampleSeries = BookSeries(context: self)
        sampleSeries.name = "Sample Series"
        
        let sampleLocation = BookLocations(context: self)
        sampleLocation.name = "Sample Location"
        
        let sampleBook = Books(context: self)
        sampleBook.title = "Sample Book"
        sampleBook.issueNumber = 1
        sampleBook.bookSeries = sampleSeries
        
        let sampleStoryArc = BookStoryArcs(context: self)
        sampleStoryArc.name = "Sample Story Arc"
        
        let sampleJoinStoryArc = JoinStoryArc(context: self)
        sampleJoinStoryArc.storyArcPart = 1
        
        do {
            try self.save()
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
}

extension Date {
    var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: self)
    }
    
    var formattedString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

