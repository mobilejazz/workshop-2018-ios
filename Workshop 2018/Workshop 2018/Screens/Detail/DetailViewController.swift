//
//  DetailViewController.swift
//  Workshop 2018
//
//  Created by Joan Martin on 17/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import UIKit
import MJSwiftCore

class DetailViewController: UITableViewController {
    
    var item : Item! = nil {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    private var loadingKids : Bool = true
    private var kids : Array<Item> = []
    
    private lazy var getItem = AppAssembler.resolver.resolve(Interactor.GetByQuery<Item>.self)!
    private lazy var getItemsById = AppAssembler.resolver.resolve(Interactor.GetItemsById.self)!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if kids.count == 0 {
            reloadData() {
                self.loadingKids = false
                self.tableView.reloadData()
            }
        }
    }
    
    // Mark - Data loading
    
    func reloadData(_ completion: @escaping () -> Void = {}) {
        getItem.execute(item.id).then { item in
            self.item = item
            }.onCompletion {
                self.getItemsById.execute(with: self.item.kids).then { items in
                    self.kids = items
                    completion()
                    }.fail { error in
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        completion()
                }
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return item == nil ? 0 : 1
        case 1:
            return kids.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ItemCell.self, for: indexPath) // <- custom MJSwiftCore method to dequeue a cell and cast it. Cell identifier must be the same as the class name by default.
        
        switch indexPath.section {
        case 0:
            cell.titleLabel.text = item.title
            cell.byLabel.text = "by @\(item.by)"
            cell.contentLabel.attributedText = item.attributtedText()
        case 1:
            let kid = kids[indexPath.row]
            cell.titleLabel.text = kid.title
            cell.byLabel.text = "by @\(kid.by)"
            cell.contentLabel.attributedText = kid.attributtedText()
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            if loadingKids {
                return "Loading \(item.kids.count) comments..."
            } else {
                if kids.count == 0 {
                    return "No comments"
                } else if kids.count == 1 {
                    return "\(kids.count) comment"
                } else {
                    return "\(kids.count) comments"
                }
            }
        default:
            return nil
        }
    }
}
