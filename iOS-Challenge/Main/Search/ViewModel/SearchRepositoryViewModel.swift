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
import RxFeedback

typealias SearchRepositoriesResponse = Result<(repositories: [Repository], nextPage: Int?), SearchServiceError>

class SearchRepositoryViewModel: BaseViewModel {
    
    private var service : SearchServiceProtocol!
    private let _reachabilityService: ReachabilityService


    
    init(service :SearchServiceProtocol = SearchService(), reachabilityService: ReachabilityService = try! DefaultReachabilityService()) {
        self.service = service
        self._reachabilityService = reachabilityService
    }

    func searchRepository(by query: String, nextPage:Int?) -> Observable<SearchRepositoriesResponse>{
        self.getRepositorys(by: query, nextPage: nextPage)
                .map { result in
                    if let err = result.error {
                        return .failure(err)
                    }else {
                        return .success((repositories: result.repositories ?? [], nextPage: result.nextPage))
                    }
            }.debug()
    }
    
    
  private func getRepositorys(by query: String, nextPage:Int?) -> Observable<SearchRepositoryResult>{
       return Observable.create { observer in
            self.service.search(by: query, page: nextPage ?? 0) { (repositories, nextPage, error) in
               if error != nil {
                   observer.onError(error!)
               }else  {
                   observer.onNext(SearchRepositoryResult(repositories: repositories, nextPage: nextPage, error: nil))
                   observer.onCompleted()
               }
            }
            return Disposables.create()
       }
    }
    
}


