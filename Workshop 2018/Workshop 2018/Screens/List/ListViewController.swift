//
//  ListViewController.swift
//  Workshop 2018
//
//  Created by Joan Martin on 17/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import UIKit

import Alamofire
import MJSwiftCore
import Lyt

class ListViewController: UITableViewController {
    
    // HTTP client used to fetch data
    // Probably, this instance would be shared via some singleton, manager or dependency injection framework.
    private let sessionManager : SessionManager = {
        
        // The HTTP client.
        let sessionManager = SessionManager()
        
        // Let's use a custom MJSwiftCore Request Adapter to inject the base URL of the API
        // Additionally, we use a custom MJSwiftCore MultiRequestAdapter that allows the usage of multiple reqeust adapters if needed
        sessionManager.adapter = MultiRequestAdapter([BaseURLRequestAdapter(URL(string:"https://hacker-news.firebaseio.com/v0")!) /*, Add other adapters here */])
        
        // If we were using OAuth, there would be a custom OAuthRequestRetrier to retry if tokens were not ok.
        // However, if multiple request retriers were needed, we could use the MJSwiftCore MultiRequestRetrier class.
        sessionManager.retrier = MultiRequestRetrier([/* Add RequestRetrier here */])
        
        return sessionManager
    }()
    
    // List of items. This is the data that the tableView shows.
    private var items : Array<Item> = []
    
    // MARK: - VC lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh(sender:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if items.count == 0 {
            // Only reload if no items were loaded before.
            reloadData()
        }
    }
    
    // MARK: - UI Management
    
    // Using @objc as this method is referenced inside a #selector call
    @objc func pullToRefresh(sender: UIRefreshControl) {
        reloadData() {
            sender.endRefreshing()
        }
    }
    
    // MARK: - Data loading
    
    func reloadData(_ completion: @escaping () -> Void = {}) {
        listOfItems(success: { items in
            self.items = items
            self.tableView.reloadData()
            completion()
        }, failure: { error in
            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completion()
        })
    }

    // This method returns a list of items fetched in a bakground thread.
    // Return closures are called in the main thread.
    func listOfItems(success: @escaping (Array<Item>) -> Void, failure: @escaping (Error) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.latestItemsIds(success: { itemIds in
                let group = DispatchGroup()
                var array : Array<Item> = []
                for id in itemIds {
                    group.enter()
                    self.itemById(id, success: { item in
                        array.append(item)
                        group.leave()
                    }, failure: { error in
                        // Nothing to do
                        group.leave()
                    })
                }
                group.notify(queue: DispatchQueue.main) {
                    success(array)
                }
            }, failure: { error in
                DispatchQueue.main.async {
                    failure(error)
                }
            })
        }
    }
    
    // This method fetches the list of item ids.
    // No threading management is done.
    func latestItemsIds(success: @escaping (Array<Int>) -> Void, failure: @escaping (Error) -> Void) {
        let path = "askstories.json"
        sessionManager.request(path).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                failure(error)
            case .success(let data):
                if let data = data as? Array<Int> {
                    success(data)
                } else {
                    // Returning custom MJSwiftCore CoreError
                    failure(CoreError.NotValid("List of item ids is not correctly formatted"));
                }
            }
        })
    }
    
    // This method fetches an item from its Id
    // No threading management is done.
    func itemById(_ id: Int, success: @escaping (Item) -> Void, failure: @escaping (Error) -> Void) {
        let path = "item/\(id).json"
        sessionManager.request(path).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                failure(error)
            case .success(let data):
                
                if let json = data as? [String : AnyObject] {
                    do {
                        let item = try json.decodeAs(Item.self) // <- custom MJSwiftCore method to easily decode from JSON and cast to a type
                        success(item)
                    } catch {
                        // Returning custom MJSwiftCore CoreError
                        failure(CoreError.NotValid("Item is not correctly formatted"));
                    }
                } else {
                    // Returning custom MJSwiftCore CoreError
                    failure(CoreError.NotValid("Item is not correctly formatted"));
                }
            }
        })
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ItemCell.self, for: indexPath) // <- custom MJSwiftCore method to dequeue a cell and cast it. Cell identifier must be the same as the class name by default.
        
        let item = items[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.byLabel.text = "by @\(item.by)"

        return cell
    }
}
