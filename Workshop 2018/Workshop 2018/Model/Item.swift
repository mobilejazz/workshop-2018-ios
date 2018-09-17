//
//  Item.swift
//  Workshop 2018
//
//  Created by Joan Martin on 17/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation

struct Item : Codable {
    
    /*
     {
     "by" : "dhouston",
     "descendants" : 71,
     "id" : 8863,
     "kids" : [ 9224, 8952, 8917, 8884, 8887, 8943, 8869, 8940, 8908, 8958, 9005, 8873, 9671, 9067, 9055, 8865, 8881, 8872, 8955, 10403, 8903, 8928, 9125, 8998, 8901, 8902, 8907, 8894, 8870, 8878, 8980, 8934, 8876 ],
     "score" : 104,
     "time" : 1175714200,
     "title" : "My YC app: Dropbox - Throw away your USB drive",
     "type" : "story",
     "url" : "http://www.getdropbox.com/u/2/screencast.html"
     }
    */
    
    enum ItemType : String, Codable {
        case job
        case story
        case comment
        case poll
        case pollopt
    }
    
    let id : Int
    let by : String
    let title : String?
    let text : String?
    let type : ItemType
    let time : Int
    let url : URL?
    let kids : Array<Int>
    
    func attributtedText() -> NSAttributedString? {
        guard let text = self.text else { return nil }
        guard let data = text.data(using: String.Encoding.utf16, allowLossyConversion: false) else { return nil }
        guard let html = try? NSMutableAttributedString(data: data,
                                                        options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
                                                        documentAttributes: nil) else { return nil }
        return html
    }
}
