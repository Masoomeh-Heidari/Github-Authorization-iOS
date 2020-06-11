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
    // control
    var searchText: String
    var shouldLoadNextPage: Bool
    var repositories: Version<[Repository]>
    var failure: SearchServiceError?
    var nextPage: String?

    init(searchText: String) {
        self.searchText = searchText
        shouldLoadNextPage = true
        repositories = Version([])
        failure = nil
        nextPage = nil
    }
}

enum SearchServiceError: Error {
    case offline
    case githubLimitReached
    case networkError
}

struct SearchQuery: Equatable {
    let searchText: String;
    let shouldLoadNextPage: Bool;
    let nextPage: String?
}

enum SearchCommand {
    case changeSearch(text: String)
    case loadMoreItems
    case gitHubResponseReceived(SearchRepositoriesResponse)
}


extension SearchState {
    static let initial = SearchState(searchText: "")

    static func reduce(state: SearchState, command: SearchCommand) -> SearchState {
        switch command {
        case .changeSearch(let text):
            return SearchState(searchText: text).mutateOne { $0.failure = state.failure }
        case .gitHubResponseReceived(let result):
            switch result {
            case let .success((repositories, nextPage)):
                return state.mutate {
                    $0.repositories = Version($0.repositories.value + repositories)
                    $0.shouldLoadNextPage = false
                    $0.nextPage = nextPage
                    $0.failure = nil
                }
            case let .failure(error):
                return state.mutateOne { $0.failure = error }
            }
        case .loadMoreItems:
            return state.mutate {
                if $0.failure == nil {
                    $0.shouldLoadNextPage = true
                }
            }
        }
    }
}


extension SearchState: Mutable {

}

extension SearchState {
    var isOffline: Bool {
        guard let failure = self.failure else {
            return false
        }

        if case .offline = failure {
            return true
        }
        else {
            return false
        }
    }

    var isLimitExceeded: Bool {
        guard let failure = self.failure else {
            return false
        }

        if case .githubLimitReached = failure {
            return true
        }
        else {
            return false
        }
    }
}
