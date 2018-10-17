//
//  ItemModule.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import Swinject
import Alamofire
import MJSwiftCore

class ItemAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // Network
        let itemNetworkDataSource = ItemNetworkDataSource(container.resolve(SessionManager.self)!)
        
        let networkDataSoure = DataSourceAssembler(get: itemNetworkDataSource)
        
        // Storage
        
        let rawStorageDataSource = DeviceStorageDataSource<Data>(UserDefaults.standard, prefix: "item")
        
        let storageDataSource = DataSourceMapper(dataSource: rawStorageDataSource, toInMapper: EncodableToDataMapper<ItemEntity>(), toOutMapper: DataToDecodableMapper<ItemEntity>())
         
        // Repository
        
        let repository = NetworkStorageRepository(network: networkDataSoure, storage: storageDataSource)
        
        let mappedRepository = GetRepositoryMapper(repository: repository, toOutMapper: ItemEntityToItemMapper())
        

        
        // Registering default interactors
        container.register(Interactor.GetByQuery<Item>.self) { _ in Interactor.GetByQuery(defaultExecutor, mappedRepository) }
        
        // Registering custom interactors
        container.register(Interactor.GetItemsById.self) { Interactor.GetItemsById(defaultExecutor, getItem: $0.resolve(Interactor.GetByQuery<Item>.self)!) }
    }
}
