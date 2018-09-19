//
//  ItemEntity.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import MJSwiftCore

struct ItemEntity : Codable, VastraTimestampStrategyDataSource {
    
    enum ItemType : String, Codable {
        case job
        case story
        case comment
        case poll
        case pollopt
    }
    
    let id : Int
    let by : String?
    let title : String?
    let text : String?
    let type : ItemType?
    let time : Int?
    let url : URL?
    let kids : [Int]?
    
    // MARK: VastraTimestampStrategyDataSource
    
    var lastUpdate: Date? = nil
    
    func expiryTimeInterval() -> Time {
        return .minutes(5)
    }
}

class ItemEntityToItemMapper : Mapper<ItemEntity,Item> {
    override func map(_ from: ItemEntity) throws -> Item {
        return Item(id: from.id,
                    by: from.by ?? "unknown",
                    title: from.title ?? "",
                    text: from.text ?? "",
                    kids: from.kids ?? [])
    }
}
