//
//  AppDelegate.swift
//  iOS-Challenge
//
//  Created by Farshad Mousalou on 1/28/20.
//  Copyright © 2020 Farshad Mousalou. All rights reserved.
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var appCoordinator: AppCoordinator!
    
    private let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator.start()
            .subscribe()
            .disposed(by: disposeBag)
        
        return true
    }


    
    // DeepLink
      func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
       
        guard let parameters = url.absoluteURL.queryParameters else { return true}
        
        appCoordinator.resumeAuthentication(with: parameters)
        
        return true
      }
    
}

