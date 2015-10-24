//
//  AppDelegate.swift
//  Done
//
//  Created by Bart Jacobs on 19/10/15.
//  Copyright © 2015 Envato Tuts+. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Fetch Main Storyboard
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Instantiate Root Navigation Controller
        let rootNavigationController = mainStoryboard.instantiateViewControllerWithIdentifier("StoryboardIDRootNavigationController") as! UINavigationController
        
        // Configure View Controller
        let viewController = rootNavigationController.topViewController as? ViewController
        
        if let viewController = viewController {
            viewController.managedObjectContext = self.managedObjectContext
        }
        
        // Configure Window
        window?.rootViewController = rootNavigationController
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {}

    func applicationDidEnterBackground(application: UIApplication) {
        saveManagedObjectContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {}

    func applicationWillTerminate(application: UIApplication) {
        saveManagedObjectContext()
    }
    
    // MARK: -
    // MARK: Core Data Stack
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Done", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // URL Persistent Store
        let URLPersistentStore = self.applicationStoresDirectory().URLByAppendingPathComponent("Done.sqlite")
        
        do {
            // Declare Options
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            
            // Add Persistent Store to Persistent Store Coordinator
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URLPersistentStore, options: options)
            
        } catch {
            let fm = NSFileManager.defaultManager()
            
            if fm.fileExistsAtPath(URLPersistentStore.path!) {
                let nameIncompatibleStore = self.nameForIncompatibleStore()
                let URLCorruptPersistentStore = self.applicationIncompatibleStoresDirectory().URLByAppendingPathComponent(nameIncompatibleStore)
                
                do {
                    // Move Incompatible Store
                    try fm.moveItemAtURL(URLPersistentStore, toURL: URLCorruptPersistentStore)
                    
                } catch {
                    let moveError = error as NSError
                    print("\(moveError), \(moveError.userInfo)")
                }
            }
            
            do {
                // Declare Options
                let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
                
                // Add Persistent Store to Persistent Store Coordinator
                try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URLPersistentStore, options: options)
                
            } catch {
                let storeError = error as NSError
                print("\(storeError), \(storeError.userInfo)")
            }
            
            // Update User Defaults
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setBool(true, forKey: "didDetectIncompatibleStore")
        }
        
        return persistentStoreCoordinator
    }()
    
    // MARK: -
    // MARK: Helper Methods
    private func saveManagedObjectContext() {
        do {
            try self.managedObjectContext.save()
        } catch {
            let saveError = error as NSError
            print("\(saveError), \(saveError.userInfo)")
        }
    }
    
    private func applicationStoresDirectory() -> NSURL {
        let fm = NSFileManager.defaultManager()
        
        // Fetch Application Support Directory
        let URLs = fm.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let applicationSupportDirectory = URLs[(URLs.count - 1)]
        
        // Create Application Stores Directory
        let URL = applicationSupportDirectory.URLByAppendingPathComponent("Stores")
        
        if !fm.fileExistsAtPath(URL.path!) {
            do {
                // Create Directory for Stores
                try fm.createDirectoryAtURL(URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                print("\(createError), \(createError.userInfo)")
            }
        }
        
        return URL
    }

    private func applicationIncompatibleStoresDirectory() -> NSURL {
        let fm = NSFileManager.defaultManager()
        
        // Create Application Incompatible Stores Directory
        let URL = applicationStoresDirectory().URLByAppendingPathComponent("Incompatible")
        
        if !fm.fileExistsAtPath(URL.path!) {
            do {
                // Create Directory for Stores
                try fm.createDirectoryAtURL(URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                print("\(createError), \(createError.userInfo)")
            }
        }
        
        return URL
    }

    private func nameForIncompatibleStore() -> String {
        // Initialize Date Formatter
        let dateFormatter = NSDateFormatter()
        
        // Configure Date Formatter
        dateFormatter.formatterBehavior = .Behavior10_4
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        return "\(dateFormatter.stringFromDate(NSDate())).sqlite"
    }

}
