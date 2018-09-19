//
//  ListViewController.swift
//  Workshop 2018
//
//  Created by Joan Martin on 17/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import UIKit

import MJSwiftCore

class ListViewController: UITableViewController {
    
    // List of items. This is the data that the tableView shows.
    private var items : Array<Item> = []
    
    private var loadingItems : Bool = true
    
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
            reloadData() {
                self.loadingItems = false
                self.tableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "item.detail" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.item = sender as? Item
        }
    }
    
    // MARK: - UI Management
    
    // Using @objc as this method is referenced inside a #selector call
    @objc func pullToRefresh(sender: UIRefreshControl) {
        reloadData() {
            sender.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Data loading

    func reloadData(_ completion: @escaping () -> Void = {}) {
        DispatchQueue.global(qos: .background).async {
            Network.askstoriesItemsIds(success: { itemIds in
                let group = DispatchGroup()
                var array : Array<Item> = []
                for id in itemIds {
                    group.enter()
                    Network.itemById(id, success: { item in
                        array.append(item)
                        group.leave()
                    }, failure: { error in
                        // Nothing to do
                        group.leave()
                    })
                }
                group.notify(queue: DispatchQueue.main) {
                    self.items = array
                    completion()
                }
            }, failure: { error in
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    completion()
                }
            })
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if loadingItems {
            return 1
        } else {
            return items.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loadingItems {
            return 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ItemCell.self, for: indexPath) // <- custom MJSwiftCore method to dequeue a cell and cast it. Cell identifier must be the same as the class name by default.
        
        let item = items[indexPath.section]
        
        cell.titleLabel.text = item.title
        cell.byLabel.text = "by @\(item.by ?? "unknown")"
        cell.contentLabel.attributedText = item.attributtedText()

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]
        performSegue(withIdentifier: "item.detail", sender: item)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if loadingItems {
                return "Loading ..."
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
