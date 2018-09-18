//
//  ItemIdsNetworkDataSource.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import MJSwiftCore
import Alamofire

class AskStoriesQuery : Query { }

class ItemIdsNetworkDataSource : GetDataSource {
    
    private let sessionManager : SessionManager
    
    init(_ sessionManager : SessionManager) {
        self.sessionManager = sessionManager
    }
    
    typealias T = Int
    
    func get(_ query: Query) -> Future<Int> {
        switch query {
        default:
            query.fatalError(.get, self)
        }
    }
    
    func getAll(_ query: Query) -> Future<[Int]> {
        switch query {
        case is AskStoriesQuery:
            return askstoriesItemsIds()
        default:
            query.fatalError(.get, self)
        }
    }
}

extension ItemIdsNetworkDataSource {
    fileprivate func askstoriesItemsIds() -> Future<[Int]> {
        let path = "askstories.json"
        return sessionManager.request(path).validate().toFuture().map { data in
            guard let ids = data as? [Int] else { throw CoreError.NotValid("Invalid json format") }
            return ids
        }
    }
}
