//
//  ViewController.swift
//  iOSBackgroundTasksStoryboard
//
//  Created by Ricardo Rodríguez on 22/11/22.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    private let viewModel = ViewModel()
    private var disposables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "EventCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.bindViewModel()
        
        self.loadData()
    }
    
    // Bind
    
    func bindViewModel() {
        
        self.viewModel.$eventList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("eventList has been changed")
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                
            }
            .store(in: &self.disposables)
        
        self.viewModel.$pendingTaskCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                var status = ""
                switch UIApplication.shared.backgroundRefreshStatus {
                case .available:
                    status = "Active"
                case .denied:
                    status = "Denied"
                case .restricted:
                    status = "Restricted"
                @unknown default:
                    status = "Unknown"
                }
                self?.statusLabel.text = "BackgroundRefreshStatus is \(status) (total:\(newValue))"
            }
            .store(in: &self.disposables)
        
        NotificationCenter.default.publisher(for: .eventListUpdated)
            .sink { [weak self] _ in
                print("Notificationd detects changes")
                self?.loadData()
            }
            .store(in: &self.disposables)
    }
    
    // Actions
    
    @objc func loadData() {
        print("Call pull to refresh")
        Task {
            await self.viewModel.loadData()
        }
    }
    
    @IBAction func performAddAppRefreshRequest(_ sender: Any) {
        self.viewModel.addAppRefreshRequest()
    }
    
    @IBAction func performAddProcessingRequest(_ sender: Any) {
        self.viewModel.addProcessingRequest()
    }
    
    @IBAction func performClearData(_ sender: Any) {
        self.viewModel.clearData()
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.numOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventCell
        let eventItem = self.viewModel.itemFor(row: indexPath.row)!
        cell.updateUI(item: eventItem)
        return cell
    }
    
}

