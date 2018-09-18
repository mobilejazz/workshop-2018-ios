//
//  ItemIdsModule.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import Swinject
import Alamofire
import MJSwiftCore

class ItemIdsAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // Network
        let itemIdsNetworkDataSource = ItemIdsNetworkDataSource(container.resolve(SessionManager.self)!)
        let networkDataSource = DataSourceAssambler(get: itemIdsNetworkDataSource, put: VoidPutDataSource(), delete: VoidDeleteDataSource())
        
        // Storage
        let userDefaultsDataSource = UserDefaultsDataSource<Int>(UserDefaults.standard, prefix: "itemIds")

        // Repository
        let repository = NetworkStorageRepository(network: networkDataSource, storage: userDefaultsDataSource)
        
        // Registering the interactor
        container.register(Interactor.GetAll<Int>.self, name: "askstories") { _ in Interactor.GetAll(defaultExecutor, repository, AskStoriesQuery()) }
    }
}
