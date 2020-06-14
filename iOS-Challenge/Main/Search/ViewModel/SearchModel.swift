//
//  SearchModel.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/22/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation
import RxSwift



struct SearchState {
    var search: String {
         didSet {
             if search.isEmpty {
                 self.nextPage = nil
                 self.shouldLoadNextPage = false
                 self.results = []
                 self.lastError = nil
                 return
             }
             self.nextPage = 0
             self.shouldLoadNextPage = true
             self.lastError = nil
         }
     }
     
     var nextPage: Int?
     var shouldLoadNextPage: Bool
     var results: [Repository]
     var lastError: SearchServiceError?
}

extension SearchState {
    var loadNextPage: SearchQuery? {
        return self.shouldLoadNextPage ? SearchQuery(searchText: search , nextPage: self.nextPage) : nil
    }
}

enum SearchServiceError: Error {
    case offline
    case githubLimitReached
    case networkError
    case unkownError
}


extension SearchServiceError {
    var displayMessage: String {
        switch self {
        case .offline:
            return "Ups, no network connectivity"
        case .githubLimitReached:
            return "Reached GitHub throttle limit, wait 60 sec"
        default:
            return "Service Error ..."
        }
    }
}

struct SearchQuery: Equatable {
    let searchText: String
    let nextPage: Int?
}

enum SearchEvent {
    case searchChanged(String)
    case response(SearchRepositoriesResponse)
    case scrollingNearBottom
}


extension SearchState {
    static var empty: SearchState {
           return SearchState(search: "", nextPage: nil, shouldLoadNextPage: true, results: [], lastError: nil)
       }

       static func reduce(state: SearchState, event: SearchEvent) -> SearchState {
           switch event {
           case .searchChanged(let search):
               var result = state
               result.search = search
               result.results = []
               return result
           case .scrollingNearBottom:
               var result = state
               result.shouldLoadNextPage = true
               return result
           case .response(.success(let response)):
               var result = state
               result.results += response.repositories
               result.shouldLoadNextPage = false
               result.nextPage = response.nextPage
               result.lastError = nil
               return result
           case .response(.failure(let error)):
               var result = state
               result.shouldLoadNextPage = false
               result.lastError = error
               return result
           }
       }
}


struct SearchRepositoryResult {
    let repositories:[Repository]?
    let nextPage :Int?
    let error:SearchServiceError?
}
