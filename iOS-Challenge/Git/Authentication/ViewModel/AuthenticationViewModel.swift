//
//  AuthenticationViewModel.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation
import RxSwift


class AuthenticationViewModel:BaseViewModel {
    
    private var service : AuthenticationServiceProtocol!
    
    let showLogin = PublishSubject<Void>()

    
    init(service :AuthenticationServiceProtocol = AuthenticationService()) {
        self.service = service
    }
    
    func authenticateUser(with code: String) -> Observable<String?>{
        return Observable.create { (observer) -> Disposable in
            self.service.authorization(with: code) { (token, error) in
                if let _ = token {
                    observer.onNext(code)
                    observer.onCompleted()
                }else if let _ = error{
                    observer.onError(error!)
                }
                
            }
            return Disposables.create()
        }
    }
}
    
