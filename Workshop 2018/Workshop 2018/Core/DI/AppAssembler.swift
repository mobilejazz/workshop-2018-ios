//
//  AppAssembler.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import Swinject
import MJSwiftCore

class AppAssembler {
    static let assembler : Assembler = Assembler([NetworkAssembly(),
                                                  ItemAssembly(),
                                                  ItemIdsAssembly()])
    
    static var resolver : Resolver {
        return assembler.resolver
    }
}

let defaultExecutor = DispatchQueueExecutor()
