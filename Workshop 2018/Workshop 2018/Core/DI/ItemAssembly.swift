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
        let networkDataSource = DataSourceAssambler(get: itemNetworkDataSource, put: VoidPutDataSource(), delete: VoidDeleteDataSource())
        
        // Storage
        let userDefaultsDataSource = UserDefaultsDataSource<Data>(UserDefaults.standard, prefix: "item")
        let itemToDataMappedDataSource = DataSourceMapper(dataSource: userDefaultsDataSource, toToMapper: EncodableToDataMapper<ItemEntity>(), toFromMapper: DataToDecodableMapper<ItemEntity>())
        let validatedDataSource = DataSourceValidator(dataSource: itemToDataMappedDataSource, validator: VastraService([VastraTimestampStrategy()]))
        
        // Repository
        let repository = NetworkStorageRepository(network: networkDataSource, storage: validatedDataSource)
        let mappedRepository = GetRepositoryMapper(repository: repository, toFromMapper: ItemEntityToItemMapper())
        

        // Registering default interactors
        container.register(Interactor.GetByQuery<Item>.self) { _ in Interactor.GetByQuery(defaultExecutor, mappedRepository) }
        
        // Registering custom interactors
        container.register(Interactor.GetItemsById.self) { Interactor.GetItemsById(defaultExecutor, getItem: $0.resolve(Interactor.GetByQuery<Item>.self)!) }
    }
}
