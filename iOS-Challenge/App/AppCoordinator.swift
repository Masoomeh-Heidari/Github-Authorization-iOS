//
//  AppCoordinator.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1398 AP Fariba. All rights reserved.
//

import Foundation
import UIKit
import RxSwift


class AppCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
        
    private let viewModel = AuthenticationViewModel()

    
    init(window: UIWindow) {
        self.window = window
    }
    
    fileprivate var isLoggedIn = false
    
    override func start() -> Observable<Void> {
        
        let viewController = AuthenticationViewController.initFromStoryboard(name: "Main")

        viewController.viewModel = viewModel
        
        let authenticationCoordinator = AuthenticationCoordinator(viewController: viewController, viewModel: viewModel)
        
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        
        
        return coordinate(to: authenticationCoordinator)

    }
    
    
     func resumeAuthentication(with parameters: QueryParameters) {
        if let code =  parameters["code"]{
            viewModel.authenticateUser(with: code).subscribe(onNext: { (token) in
                
                self.saveTokenToKeychain(token: token)
                self.coordinateToSearchRepository()
                
            }, onError: { (error) in
                print(error)
                
            }).disposed(by: disposeBag)
        }
     }
    
    func saveTokenToKeychain(token :String)  {
        if let savedToken = KeychainManager.loadToken(), savedToken != token {
            KeychainManager.updateToken(data: token)
        }else {
            KeychainManager.saveToken(data: token)
        }
    }
    
    func coordinateToSearchRepository(){
        let viewModel = SearchRepositoryViewModel()
        let viewController = SearchRepositoryViewController()
        viewController.viewModel = viewModel
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        let searchRepoCoordinator = SearchRepositoryCoordinator(viewController: viewController, viewModel: viewModel)
        self.coordinate(to: searchRepoCoordinator).subscribe().disposed(by: self.disposeBag)
        
        window.rootViewController = navigationController
    }
    
}


