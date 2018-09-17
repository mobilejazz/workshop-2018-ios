//
//  Network.swift
//  Workshop 2018
//
//  Created by Joan Martin on 17/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation

import Alamofire
import MJSwiftCore

struct Network {
    
    // HTTP client used to fetch data
    private static let sessionManager : SessionManager = {
        
        // The HTTP client.
        let sessionManager = SessionManager()
        
        // Let's use a custom MJSwiftCore Request Adapter to inject the base URL of the API
        // Additionally, we use a custom MJSwiftCore MultiRequestAdapter that allows the usage of multiple reqeust adapters if needed
        sessionManager.adapter = MultiRequestAdapter([BaseURLRequestAdapter(URL(string:"https://hacker-news.firebaseio.com/v0")!) /*, Add other adapters here */])
        
        // If we were using OAuth, there would be a custom OAuthRequestRetrier to retry if tokens were not ok.
        // However, if multiple request retriers were needed, we could use the MJSwiftCore MultiRequestRetrier class.
        sessionManager.retrier = MultiRequestRetrier([/* Add RequestRetrier here */])
        
        return sessionManager
    }()
        
    // This method fetches the list of item ids.
    // No threading management is done.
    static func askstoriesItemsIds(success: @escaping (Array<Int>) -> Void, failure: @escaping (Error) -> Void) {
        let path = "askstories.json"
        sessionManager.request(path).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                failure(error)
            case .success(let data):
                if let data = data as? Array<Int> {
                    success(data)
                } else {
                    // Returning custom MJSwiftCore CoreError
                    failure(CoreError.NotValid("List of item ids is not correctly formatted"));
                }
            }
        })
    }
    
    // This method fetches an item from its Id
    // No threading management is done.
    static func itemById(_ id: Int, success: @escaping (Item) -> Void, failure: @escaping (Error) -> Void) {
        let path = "item/\(id).json"
        sessionManager.request(path).validate().responseJSON(completionHandler: { response in
            switch response.result {
            case .failure(let error):
                failure(error)
            case .success(let data):
                
                if let json = data as? [String : AnyObject] {
                    do {
                        let item = try json.decodeAs(Item.self) // <- custom MJSwiftCore method to easily decode from JSON and cast to a type
                        success(item)
                    } catch {
                        // Returning custom MJSwiftCore CoreError
                        failure(CoreError.NotValid("Item is not correctly formatted"));
                    }
                } else {
                    // Returning custom MJSwiftCore CoreError
                    failure(CoreError.NotValid("Item is not correctly formatted"));
                }
            }
        })
    }
}
