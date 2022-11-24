//
//  AppDelegate.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 22/11/22.
//

import UIKit
import CoreData
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        self.registerBackgroundTasks()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "iOSBackgroundTasksStoryboard")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


// Background Tasks

extension AppDelegate {
    
    func registerBackgroundTasks() {
        let appRefreshTaskIdentifier = "demo.task.appRefresh"
        let processingTaskIdentifier = "demo.task.processing"
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: appRefreshTaskIdentifier, using: nil) { task in
            UserDefaults.standard.appRefreshTaskStatus = .finished
            DataRepository.shared.updateAsExecuted(.appRefresh)
            print("appRefresh has been executed!")
            task.setTaskCompleted(success: true)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: processingTaskIdentifier, using: nil) { task in
            UserDefaults.standard.processingTaskStatus = .finished
            DataRepository.shared.updateAsExecuted(.processing)
            print("processing has been executed!")
            task.setTaskCompleted(success: true)
        }
    }
    
    func scheduleBackgroundTasks() {
        self.scheduleAppRefreshTask()
        self.scheduleProcessingTask()
    }
    
    private func scheduleAppRefreshTask() {
        guard UserDefaults.standard.appRefreshTaskStatus == .waiting else { return }
        let taskRequest = BGProcessingTaskRequest(identifier: "demo.task.appRefresh")
        do {
            let extraTime: TimeInterval = 10
            let expectedTime = Date(timeIntervalSinceNow: extraTime)
            taskRequest.earliestBeginDate = expectedTime
            try BGTaskScheduler.shared.submit(taskRequest)
            DataRepository.shared.updateAsScheduled(.appRefresh, expectedTime: expectedTime)
            UserDefaults.standard.appRefreshTaskStatus = .scheduled
        } catch {
            print(error)
            DataRepository.shared.updateAsError(.appRefresh)
            UserDefaults.standard.appRefreshTaskStatus = .error
        }
    }
    
    private func scheduleProcessingTask() {
        guard UserDefaults.standard.processingTaskStatus == .waiting else { return }
        let taskRequest = BGAppRefreshTaskRequest(identifier: "demo.task.processing")
        do {
            let extraTime: TimeInterval = 10
            let expectedTime = Date(timeIntervalSinceNow: extraTime)
            taskRequest.earliestBeginDate = expectedTime
            try BGTaskScheduler.shared.submit(taskRequest)
            DataRepository.shared.updateAsScheduled(.processing, expectedTime: expectedTime)
            UserDefaults.standard.processingTaskStatus = .scheduled
        } catch {
            print(error)
            DataRepository.shared.updateAsError(.processing)
            UserDefaults.standard.processingTaskStatus = .error
        }
    }
    
}
