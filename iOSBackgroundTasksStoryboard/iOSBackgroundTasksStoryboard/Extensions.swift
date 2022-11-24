//
//  Extensions.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 23/11/22.
//

import Foundation

extension Date {
    
    func toString() -> String {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd\n(HH:mm:ss)"
        return format.string(from: self)
    }
    
}
