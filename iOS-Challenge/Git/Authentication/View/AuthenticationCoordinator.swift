//
//  AuthenticationCoordinator.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation
import RxSwift
import SafariServices


typealias QueryParameters = [String : String]


class AuthenticationCoordinator: BaseCoordinator<Void> {
    

    private let viewModel: AuthenticationViewModel
    private let viewController: AuthenticationViewController
    
    init(viewController: UIViewController,viewModel: BaseViewModel) {
        self.viewModel = viewModel as! AuthenticationViewModel
        self.viewController = viewController as! AuthenticationViewController
    }
    
    override func start() -> Observable<Void> {


        viewModel.showLogin
            .bind(onNext: { (token) in
                self.showLogin(in: self.viewController)
            })
            .disposed(by: disposeBag)



        return Observable.never()
        
    }
    
    private func showLogin(in viewController: UIViewController) {
        let safariViewController = SFSafariViewController(url: URL(string: API.LOGIN_URL)!)
          viewController.present(safariViewController, animated: true)
      }
    
}
