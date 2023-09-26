//
//  ComixCrateApp.swift
//  ComixCrate
//
//  Created by Ben Carney on 9/16/23.
//

import SwiftUI
import CoreData

@main
struct ComixCrateApp: App {
    
    @StateObject private var dataController = DataController()
    var container: NSPersistentContainer!
    
    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
