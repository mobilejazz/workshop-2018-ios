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
    
    private let sessionManager : SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.adapter = MultiRequestAdapter([BaseURLRequestAdapter(URL(string:"https://hacker-news.firebaseio.com/v0")!)])
        return sessionManager
    }()
    
    private var items : Array<Item> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if items.count == 0 {
            indicatorView.startAnimating()
            listOfItems(success: { items in
                self.indicatorView.stopAnimating()
                self.items = items
                self.tableView.reloadData()
            }, failure: { error in
                self.indicatorView.stopAnimating()
                print("error: \(error)")
            })
        }
    }

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
    
    func latestItemsIds(success: @escaping (Array<Int>) -> Void, failure: @escaping (Error) -> Void) {
        let url = "askstories.json"
        sessionManager.request(url).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                failure(error)
            case .success(let data):
                success(data as! Array<Int>)
            }
        })
    }
    
    func itemById(_ id: Int, success: @escaping (Item) -> Void, failure: @escaping (Error) -> Void) {
        let url = "item/\(id).json"
        sessionManager.request(url).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                failure(error)
            case .success(let data):
                if let json = data as? [String : AnyObject] {
                    do {
                        let item = try json.decodeAs(Item.self)
                        success(item)
                    } catch {
                        failure(CoreError.NotValid("Item is not correctly formatted"));
                    }
                } else {
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
        let cell = tableView.dequeueReusableCell(ItemCell.self, for: indexPath)
        
        let item = items[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.byLabel.text = item.by

        return cell
    }
}
