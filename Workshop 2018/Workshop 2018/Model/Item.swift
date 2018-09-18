//
//  Item.swift
//  Workshop 2018
//
//  Created by Joan Martin on 17/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation

struct Item {
    let by : String
    let title : String
    let text : String
    let kids : Array<Int>
    
    func attributtedText() -> NSAttributedString? {
        guard let data = text.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(data: data,
                                                        options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                                        documentAttributes: nil) else { return nil }
        return html
    }
}
