//
//  AuthenticationViewController.swift
//  iOS-Challenge
//
//  Created by Farshad Mousalou on 1/28/20.
//  Copyright © 2020 Farshad Mousalou. All rights reserved.
//

import UIKit
import RxCocoa

class AuthenticationViewController: UIViewController,StoryboardInitializable {

    @IBOutlet weak var accessTokenLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!

    
    var viewModel: AuthenticationViewModel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.rx.tap.asObservable().bind(to: viewModel.showLogin).disposed(by: viewModel.disposeBag)
    }

}



