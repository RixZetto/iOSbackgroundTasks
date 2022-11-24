//
//  ViewModel.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 22/11/22.
//

import Foundation
import Combine
import BackgroundTasks

class ViewModel {
    
    @Published var eventList: [Event]?
    @Published var pendingTaskCount: Int = 0
    
    func loadData() async {
        print("Will LoadData (current: \(self.eventList?.count ?? 0) items)")
        self.eventList = DataRepository.shared.list()
        print("Did LoadData \(self.eventList?.count ?? 0) items" )
        let pendingTasks = await BGTaskScheduler.shared.pendingTaskRequests()
        for pendingTask in pendingTasks {
            print("\(pendingTask.identifier)")
        }
        self.pendingTaskCount = pendingTasks.count
    }
    
    func numOfRows() -> Int {
        return self.eventList?.count ?? 0
    }
    
    func itemFor(row: Int) -> Event? {
        return self.eventList?[row] ?? nil
    }
    
    // Refresh Task
    
    func clearData() {
        UserDefaults.standard.processingTaskStatus = .none
        UserDefaults.standard.appRefreshTaskStatus = .none
        DataRepository.shared.clearAll()
    }
    
    @discardableResult
    func addAppRefreshRequest() -> Event?  {
        guard UserDefaults.standard.appRefreshTaskStatus == .none ||
              UserDefaults.standard.appRefreshTaskStatus == .finished
        else {
            return nil
        }
        UserDefaults.standard.appRefreshTaskStatus = .waiting
        return DataRepository.shared.save(.appRefresh)
    }
    
    @discardableResult
    func addProcessingRequest() -> Event? {
        guard UserDefaults.standard.processingTaskStatus == .none ||
              UserDefaults.standard.processingTaskStatus == .finished
        else {
            return nil
        }
        UserDefaults.standard.processingTaskStatus = .waiting
        return DataRepository.shared.save(.processing)
    }
    
}
