//
//  SignupBaseViewModel.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1398 AP Fariba. All rights reserved.
//

import Foundation
import RxSwift

typealias errorActionCompletion = (() -> Void)?

class BaseViewModel {
    
    let errorMessage = BehaviorSubject<String>(value: "")
    let disposeBag = DisposeBag()
    
    
    //MARK:- Service response handler
//    func process(responseStatus: Bool ,_ error: ErrorModel?) {
//        Utility.hideHUD()
//        responseStatus ? self.serviceSucceed() : self.serviceError(error!)
//    }
//    
//    func serviceSucceed() {
//        Utility.hideHUD()
//    }
//    
//    func serviceFailure(_ message: String?, _ completion: errorActionCompletion = nil) {
//        Utility.showActionMessage(title: "خطا", message: message ?? "", actions: getErrorAction(completion))
//    }
//    
//    func serviceError(_ error: ErrorModel, _ completion: errorActionCompletion = nil) {
//        Utility.showActionMessage(title: "خطا", message: error.status_message ?? "error......" , actions: getErrorAction(completion))
//    }
//    
//    fileprivate func getErrorAction(_ completion: errorActionCompletion = nil) -> [MMPopupItem] {
//        let action = Utility.actionMessageCancel({
//            completion?()
//        })
//        return [action]
//    }
    
}


