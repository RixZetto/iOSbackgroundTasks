//
//  EventCel.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 22/11/22.
//

import Foundation
import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var creationTimeLabel: UILabel!
    @IBOutlet weak var expectedTimeLabel: UILabel!
    @IBOutlet weak var executedTimeLabel: UILabel!
    
    func updateUI(item: Event) {
        self.statusLabel.text = (item.type ?? "(unknown)") + ":" + (item.status ?? "-")
        self.creationTimeLabel.text = "Created: " + (item.creationDate?.toString() ?? "-")
        self.expectedTimeLabel.text = "Expected: " + (item.expectedTime?.toString() ?? "-")
        self.executedTimeLabel.text = item.executedTime?.toString() ?? "-"
    }
    
}

