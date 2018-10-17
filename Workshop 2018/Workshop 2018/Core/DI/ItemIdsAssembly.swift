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
        let networkDataSoure = DataSourceAssembler(get: itemIdsNetworkDataSource)
        
        // Cache
        let storageDataSource = DeviceStorageDataSource<Int>(UserDefaults.standard, prefix: "item.id")
    
        let repository = NetworkStorageRepository(network: networkDataSoure, storage: storageDataSource)
        
        // Registering the interactor
        container.register(Interactor.GetAll<Int>.self, name: "askstories") { _ in Interactor.GetAll(defaultExecutor, repository, AskStoriesQuery()) }
    }
}
