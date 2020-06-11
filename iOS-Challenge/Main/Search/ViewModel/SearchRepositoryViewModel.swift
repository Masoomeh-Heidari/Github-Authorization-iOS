//
//  SearchRepositoryViewModel.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//



import Foundation
import RxSwift
import RxCocoa


typealias SearchRepositoriesResponse = Result<(repositories: [Repository], nextPage: String?), SearchServiceError>

class SearchRepositoryViewModel: BaseViewModel {
    
    private var service : SearchServiceProtocol!
    private let _reachabilityService: ReachabilityService


    
    init(service :SearchServiceProtocol = SearchService(), reachabilityService: ReachabilityService = try! DefaultReachabilityService()) {
        self.service = service
        self._reachabilityService = reachabilityService
    }
    
    func searchRepository(by query: String) -> Observable<SearchRepositoriesResponse>{
        return Observable.create { (observer) -> Disposable in
            self.service.search(by: query) { (repositories, nextPage, error) in
                if error == .githubLimitReached {
                    return .failure(.githubLimitReached)
                }else {
                    return .success((repositories: repositories, nextPage: nextPage))
                }
            }
            return Disposables.create()
        }
    }
    

    func createState(
            searchText: Signal<String>,
            loadNextPageTrigger: @escaping (Driver<SearchState>) -> Signal<()>,
            performSearch: @escaping (String) -> Observable<SearchRepositoriesResponse>
        ) -> Driver<SearchState> {

        let searchPerformerFeedback: (Driver<SearchState>) -> Signal<SearchCommand> = react(
            query: { (state) in
                SearchQuery(searchText: state.searchText, shouldLoadNextPage: state.shouldLoadNextPage, nextPage: state.nextPage)
            },
            effects: { query -> Signal<SearchCommand> in
                    if !query.shouldLoadNextPage {
                        return Signal.empty()
                    }

                    if query.searchText.isEmpty {
                        return Signal.just(SearchCommand.gitHubResponseReceived(.success((repositories: [], nextPage: nil))))
                    }

                    guard let nextPage = query.nextPage else {
                        return Signal.empty()
                    }

                    return performSearch(nextPage)
                        .asSignal(onErrorJustReturn: .failure(SearchServiceError.networkError))
                        .map(SearchCommand.gitHubResponseReceived)
                }
        )

        // this is degenerated feedback loop that doesn't depend on output state
        
        let inputFeedbackLoop: (Driver<SearchState>) -> Signal<SearchCommand> = { state in
                
                let loadNextPage = loadNextPageTrigger(state).map { _ in SearchCommand.loadMoreItems }
                
                let searchText = searchText.map(SearchCommand.changeSearch)

                return Signal.merge(loadNextPage, searchText)
        }

        // Create a system with two feedback loops that drive the system
        // * one that tries to load new pages when necessary
        // * one that sends commands from user input
        return Driver.system(
            initialState: SearchState.initial,
            reduce: SearchState.reduce,
            feedback: searchPerformerFeedback, inputFeedbackLoop
        )
    }
    
}


