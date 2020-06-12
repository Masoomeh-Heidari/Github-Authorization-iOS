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


typealias SearchRepositoriesResponse = Result<(repositories: [Repository], nextPage: Int?), SearchServiceError>

class SearchRepositoryViewModel: BaseViewModel {
    
    private var service : SearchServiceProtocol!
    private let _reachabilityService: ReachabilityService


    
    init(service :SearchServiceProtocol = SearchService(), reachabilityService: ReachabilityService = try! DefaultReachabilityService()) {
        self.service = service
        self._reachabilityService = reachabilityService
    }
    
    func searchRepository(by query: String, nextPage:Int ) -> Observable<SearchRepositoriesResponse>{
        Observable.create { (observer) -> Disposable in
            self.service.search(by: query, page: nextPage) { (repositories, nextPage, error) in
                if error != nil {
                    observer.onError(error!)
                }else  {
                    observer.onNext(.success((repositories: repositories ?? [], nextPage: nextPage)))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }.debug()
    }
    

    func createState(
        searchText: Signal<String>,
        loadNextPageTrigger: @escaping (Driver<SearchState>) -> Signal<()>,
        performSearch: @escaping (String, Int) -> Observable<SearchRepositoriesResponse>
    ) -> Driver<SearchState> {
        
        let searchPerformerFeedback: (Driver<SearchState>) -> Signal<SearchCommand> = react(
            query: { (state) in
                SearchQuery(searchText: state.searchText, shouldLoadNextPage: state.shouldLoadNextPage, nextPage: state.nextPage)
            },
            effects: { query -> Signal<SearchCommand> in
                if !query.shouldLoadNextPage {
                    return Signal.empty().debug()
                }
                
                if query.searchText.isEmpty {
                    return Signal.just(SearchCommand.gitHubResponseReceived(.success((repositories: [], nextPage: nil)))).debug()
                }
                
                guard let nextPage = query.nextPage else {
                    return Signal.empty()
                }
                
                return performSearch(query.searchText, nextPage)
                    .asSignal(onErrorJustReturn: .failure(SearchServiceError.networkError)).debug()
                    .map(SearchCommand.gitHubResponseReceived).debug()
        }
        )

        // this is degenerated feedback loop that doesn't depend on output state
        
        let inputFeedbackLoop: (Driver<SearchState>) -> Signal<SearchCommand> = { state in
            
            let loadNextPage = loadNextPageTrigger(state).map { _ in SearchCommand.loadMoreItems }.debug()
            
            let searchText = searchText.map(SearchCommand.changeSearch).debug()
            
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


