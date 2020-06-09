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
                KeychainManager.saveToken(data: token!)
                
                let searchRepoCoordinator = SearchRepoCoordinator()
                self.coordinate(to: searchRepoCoordinator).subscribe().disposed(by: self.disposeBag)
            }, onError: { (error) in
                print(error)
                
            }).disposed(by: disposeBag)
        }
     }
}


