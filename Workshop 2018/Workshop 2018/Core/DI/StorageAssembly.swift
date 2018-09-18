//
//  StorageAssembly.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import Swinject
import Alamofire
import MJSwiftCore

class StorageAssembly: Assembly {
    
    func assemble(container: Container) {
        
    }
}


// Make Vastra compliant with ObjectValidation
extension VastraService : ObjectValidation { }
