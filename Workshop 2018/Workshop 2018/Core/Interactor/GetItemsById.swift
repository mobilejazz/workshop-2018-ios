//
//  GetItemsByIdInteractor.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import MJSwiftCore

extension Interactor {
    
    class GetItemsById {
        
        private let executor : Executor
        private let getItem : GetByQuery<Item>
        
        init(_ executor : Executor, getItem: GetByQuery<Item>) {
            self.executor = executor
            self.getItem = getItem
        }
        
        // Serial execution method
//        func execute(with itemIds: [Int]) -> Future<[Item]> {
//            return executor.submit { resolver in
//                let items = try itemIds.map { try self.getItem.execute($0, in: DirectExecutor()).result.get() }
//                resolver.set(items)
//            }
//        }
        
        // Parallel execution method
        func execute(with itemIds: [Int]) -> Future<[Item]> {
            return executor.submit { resolver in

                // Custom operation queue to parallelize requests
                let operationQueue = OperationQueue()
                operationQueue.maxConcurrentOperationCount = 20 // <- max of 20 requests
                let operationQueueExecutor = OperationQueueExecutor(operationQueue)

                // Note: we are assuming here the data sources used in getItem are thread safe!
                let future = FutureBatch.array(itemIds.map { self.getItem.execute($0, in: operationQueueExecutor) })
                resolver.set(future)
            }
        }
    }
}
