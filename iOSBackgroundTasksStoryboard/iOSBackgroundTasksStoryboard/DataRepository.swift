//
//  DataRepository.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 22/11/22.
//

import Foundation
import CoreData
import UIKit

class DataRepository {
    
    static let shared = DataRepository()
    
    lazy var context = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        return context
    }()
    
    func clearAll() {
        defer {
            NotificationCenter.default.post(name: .eventListUpdated, object: nil)
        }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Event")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func list() -> [Event] {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        do {
            let totalCount = try context.count(for: fetchRequest)
            fetchRequest.fetchOffset = 0
            fetchRequest.fetchLimit = 30
            
            let dateSort = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchRequest.sortDescriptors = [dateSort]
            
            do {
                return try context.fetch(fetchRequest)
            }
        } catch {
            print(error)
        }
        return []
    }
    
    @discardableResult
    func save(_ eventType: EventType) -> Event? {
        let entity = NSEntityDescription.entity(forEntityName: "Event", in: context)
        let newEvent = NSManagedObject(entity: entity!, insertInto: context)
        let creationDate = Date()
        newEvent.setValue(eventType.rawValue, forKey: "type")
        newEvent.setValue(creationDate, forKey: "creationDate")
        newEvent.setValue(EventStatus.waiting.rawValue, forKey: "status")
        do {
            try context.save()
            NotificationCenter.default.post(name: .eventListUpdated, object: nil)
            return newEvent as? Event
        } catch {
            print(error)
        }
        return nil
    }
    
    @discardableResult
    func updateAsScheduled(_ eventType: EventType, expectedTime: Date) -> Event? {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.predicate = NSPredicate(format: "status == %@ && type == %@", EventStatus.waiting.rawValue, eventType.rawValue)
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                results.first?.status = EventStatus.scheduled.rawValue
                results.first?.expectedTime = expectedTime
                try context.save()
                NotificationCenter.default.post(name: .eventListUpdated, object: nil)
                return results.first
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    @discardableResult
    func updateAsExecuted(_ eventType: EventType) -> Event? {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.predicate = NSPredicate(format: "status == %@ && type == %@", EventStatus.scheduled.rawValue, eventType.rawValue)
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                results.first?.status = EventStatus.finished.rawValue
                results.first?.executedTime = Date()
                try context.save()
                NotificationCenter.default.post(name: .eventListUpdated, object: nil)
                return results.first
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    @discardableResult
    func updateAsError(_ eventType: EventType) -> Event? {
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.predicate = NSPredicate(format: "status == %@ && type == %@", EventStatus.waiting.rawValue, eventType.rawValue)
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                results.first?.status = EventStatus.error.rawValue
                try context.save()
                NotificationCenter.default.post(name: .eventListUpdated, object: nil)
                return results.first
            }
        } catch {
            print(error)
        }
        return nil
    }
    
}
