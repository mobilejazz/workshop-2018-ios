//
//  NetworkAssembly.swift
//  Workshop 2018
//
//  Created by Joan Martin on 18/09/2018.
//  Copyright © 2018 Mobile Jazz. All rights reserved.
//

import Foundation
import Swinject
import Alamofire
import MJSwiftCore

class NetworkAssembly: Assembly {
    
    func assemble(container: Container) {
        // Alamofire Session Manager
        container.register(SessionManager.self) { r in
            // The HTTP client.
            let sessionManager = SessionManager()
            
            // Let's use a custom MJSwiftCore Request Adapter to inject the base URL of the API
            // Additionally, we use a custom MJSwiftCore MultiRequestAdapter that allows the usage of multiple reqeust adapters if needed
            sessionManager.adapter = MultiRequestAdapter([BaseURLRequestAdapter(URL(string:"https://hacker-news.firebaseio.com/v0")!) /*, Add other adapters here */])
            
            // If we were using OAuth, there would be a custom OAuthRequestRetrier to retry if tokens were not ok.
            // However, if multiple request retriers were needed, we could use the MJSwiftCore MultiRequestRetrier class.
            sessionManager.retrier = MultiRequestRetrier([/* Add RequestRetrier here */])
            
            return sessionManager
        }
    }
}
