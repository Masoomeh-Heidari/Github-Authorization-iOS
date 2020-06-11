//
//  SearchRepositoryCoordinator.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation
import RxSwift


class SearchRepositoryCoordinator: BaseCoordinator<Void> {
    
     private let viewModel: SearchRepositoryViewModel
     private let viewController: SearchRepositoryViewController
          
     init(viewController: UIViewController,viewModel: BaseViewModel) {
         self.viewModel = viewModel as! SearchRepositoryViewModel
         self.viewController = viewController as! SearchRepositoryViewController
     }
     
    
    override func start() -> Observable<Void> {

        
        
        return Observable.never()
    }
}
