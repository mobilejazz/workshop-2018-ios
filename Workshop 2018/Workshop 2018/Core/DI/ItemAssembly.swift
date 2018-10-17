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
import Reachability

class ItemAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // Network
        let itemNetworkDataSource = ItemNetworkDataSource(container.resolve(SessionManager.self)!)
        let networkDataSource = DataSourceAssembler(get: itemNetworkDataSource, put: VoidPutDataSource(), delete: VoidDeleteDataSource())
        
        // Storage
        let userDefaultsDataSource = DeviceStorageDataSource<Data>(UserDefaults.standard, prefix: "item")
        let itemToDataMappedDataSource = DataSourceMapper(dataSource: userDefaultsDataSource, toInMapper: EncodableToDataMapper<ItemEntity>(), toOutMapper: DataToDecodableMapper<ItemEntity>())
        
        let vastra = VastraService([VastraReachabilityStrategy(Reachability()!),
                                    VastraTimestampStrategy()])
        
        let validatedDataSource = DataSourceValidator(dataSource: itemToDataMappedDataSource, validator: vastra)
        
        // Repository
        let repository = NetworkStorageRepository(network: networkDataSource, storage: validatedDataSource)
        let mappedRepository = GetRepositoryMapper(repository: repository, toOutMapper: ItemEntityToItemMapper())
        

        
        // Registering default interactors
        container.register(Interactor.GetByQuery<Item>.self) { _ in Interactor.GetByQuery(defaultExecutor, mappedRepository) }
        
        // Registering custom interactors
        container.register(Interactor.GetItemsById.self) { Interactor.GetItemsById(defaultExecutor, getItem: $0.resolve(Interactor.GetByQuery<Item>.self)!) }
    }
}

extension Reachability : VastraReachability {
    public func isReachable() -> Bool {
        return self.connection != .none
    }
}

// Make Vastra compliant with ObjectValidation
extension VastraService : ObjectValidation { }
