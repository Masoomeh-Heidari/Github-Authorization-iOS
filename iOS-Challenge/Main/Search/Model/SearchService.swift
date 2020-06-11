//
//  SearchService.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation


typealias searchRepositoryCallback = (( _ repositories: [Repository],_  nextPage: String?, _ error: SearchServiceError)-> SearchRepositoriesResponse)


protocol SearchServiceProtocol {
        func search(by text:String, callback:@escaping searchRepositoryCallback)
}


class SearchService:SearchServiceProtocol {
    
    let requestManager:RequestManagerProtocol
    let decoder = JSONDecoder()
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
    }
    
    func search(by text:String, callback:@escaping searchRepositoryCallback){
        requestManager.callAPI(requestConvertible: SearchRouter.searchRepo(query: text)) { (data, error) in
            
        }
    }
}
