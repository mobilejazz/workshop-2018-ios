//
//  ItemNetworkDataSource.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import MJSwiftCore
import Alamofire

class ItemNetworkDataSource : GetDataSource {
    
    private let sessionManager : SessionManager
    
    init(_ sessionManager : SessionManager) {
        self.sessionManager = sessionManager
    }
    
    typealias T = ItemEntity
    
    func get(_ query: Query) -> Future<ItemEntity> {
        switch query {
        case let query as IdQuery<Int>:
            return itemById(query.id)
        default:
            query.fatalError(.get, self)
        }
    }
    
    func getAll(_ query: Query) -> Future<[ItemEntity]> {
        switch query {
        default:
            query.fatalError(.getAll, self)
        }
    }
}

extension ItemNetworkDataSource {
    fileprivate func itemById(_ id: Int) -> Future<ItemEntity> {
        let path = "item/\(id).json"
        return sessionManager.request(path).validate().toFuture().map { data in
            // First, verify that the JSON data comes in the correct format
            guard let json = data as? [String:AnyObject] else { throw CoreError.NotValid("Invalid data format") }
            
            // Finally, decode the json data
            var item = try json.decodeAs(ItemEntity.self)
            
            // Store last update
            item.lastUpdate = Date()
            return item
        }
    }
}
