//
//  EventModel.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 22/11/22.
//

import Foundation

enum EventType: String {
    case appRefresh = "appRefresh"
    case processing = "processing"
}

enum EventStatus: String {
    case none
    case waiting
    case scheduled
    case finished
    case error
}

struct EventModel {
    let type: EventType
    let creationDate = Date()
    let executedTime: Date
    let expectedTime: Date
}
