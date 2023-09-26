//
//  Extensions.swift
//  ComixCrateTestTest
//
//  Created by Ben Carney on 9/24/23.
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
        let sampleSeries1 = BookSeries(context: context)
        sampleSeries1.name = "Sample Series 1"
        
        let sampleSeries2 = BookSeries(context: context)
        sampleSeries2.name = "Sample Serie 2"
        
        let sampleSeries3 = BookSeries(context: context)
        sampleSeries3.name = "Sample Seri 3"
        
        let sampleSeries4 = BookSeries(context: context)
        sampleSeries4.name = "Sample Ser 4"
        
        let sampleSeries5 = BookSeries(context: context)
        sampleSeries5.name = "Sample Se 5"
        
        let sampleSeries6 = BookSeries(context: context)
        sampleSeries6.name = "Sample S 6"
        
        // Add sample data for Books and set up the relationship with BookSeries
        let sampleBook1 = Books(context: context)
        sampleBook1.title = "Sample Book 1"
        sampleBook1.issueNumber = 1
        sampleBook1.bookSeries = sampleSeries1
        
        let sampleBook2 = Books(context: context)
        sampleBook2.title = "Sample Book 2"
        sampleBook2.issueNumber = 2
        sampleBook2.bookSeries = sampleSeries2
        
        let sampleBook3 = Books(context: context)
        sampleBook3.title = "Sample Book 3"
        sampleBook3.issueNumber = 3
        sampleBook3.bookSeries = sampleSeries3
        
        let sampleBook4 = Books(context: context)
        sampleBook4.title = "Sample Book 4"
        sampleBook4.issueNumber = 4
        sampleBook4.bookSeries = sampleSeries4
        
        let sampleBook5 = Books(context: context)
        sampleBook5.title = "Sample Book 5"
        sampleBook5.issueNumber = 5
        sampleBook5.bookSeries = sampleSeries5
        
        let sampleBook6 = Books(context: context)
        sampleBook6.title = "Sample Book 6"
        sampleBook6.issueNumber = 6
        sampleBook6.bookSeries = sampleSeries6
        
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
        
        do {
            try self.save()
        } catch {
            print("Failed to save sample data: \(error)")
        }
    }
}



