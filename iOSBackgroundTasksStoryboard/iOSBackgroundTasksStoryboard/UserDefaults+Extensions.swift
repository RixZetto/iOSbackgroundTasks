//
//  UserDefaults+Extensions.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 22/11/22.
//

import Foundation

extension UserDefaults {
    
    var appRefreshTaskStatus: EventStatus {
        get {
            if let currentStatus = string(forKey: "appRefreshTaskStatus") {
                return EventStatus(rawValue: currentStatus) ?? EventStatus.none
            }
            return EventStatus.none
        }
        set {
            set(newValue.rawValue, forKey: "appRefreshTaskStatus")
        }
    }
    var processingTaskStatus: EventStatus {
        get {
            if let currentStatus = string(forKey: "processingTaskStatus") {
                return EventStatus(rawValue: currentStatus) ?? EventStatus.none
            }
            return EventStatus.none
        }
        set {
            set(newValue.rawValue, forKey: "processingTaskStatus")
        }
    }
    
}
