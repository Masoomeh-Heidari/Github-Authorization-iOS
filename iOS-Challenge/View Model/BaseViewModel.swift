//
//  SignupBaseViewModel.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1398 AP Fariba. All rights reserved.
//

import Foundation
import RxSwift

class BaseViewModel {
    
    let errorMessage = BehaviorSubject<String>(value: "")
    let disposeBag = DisposeBag()

}


