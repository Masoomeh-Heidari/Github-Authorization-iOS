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

let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class AuthenticationCoordinator: BaseCoordinator<Void> {
    

    private let viewModel: AuthenticationViewModel
    private let viewController: AuthenticationViewController
    
    private var safariViewController: SFSafariViewController?
    
    init(viewController: UIViewController,viewModel: BaseViewModel) {
        self.viewModel = viewModel as! AuthenticationViewModel
        self.viewController = viewController as! AuthenticationViewController
    }
    
    override func start() -> Observable<Void> {

        NotificationCenter.default.addObserver(self, selector: #selector(dismissSafari), name: NSNotification.Name(rawValue: kCloseSafariViewControllerNotification), object: nil)

        viewModel.showLogin
            .bind(onNext: { (token) in
                self.showLogin(in: self.viewController)
            })
            .disposed(by: disposeBag)

        return Observable.never()
        
    }
    
    private func showLogin(in viewController: UIViewController) {
        let queryString = (["client_id":API.CLIENT_ID,"redirect_uri":API.REDIRECT_URI] as [String : Any]).queryString
        let url : URL? = URL.init(string: API.LOGIN_URL + queryString)
         safariViewController = SFSafariViewController(url: url!)
         viewController.present(safariViewController!, animated: true)
      }
    
    @objc private func dismissSafari(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kCloseSafariViewControllerNotification), object: nil)
        safariViewController?.dismiss(animated: true, completion: nil)
    }
    
}
