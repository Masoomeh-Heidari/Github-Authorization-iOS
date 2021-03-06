//
//  AuthenticationService.swift
//  iOS-Challenge

//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1398 AP Fariba. All rights reserved.
//

import Foundation

typealias authorizationCallback = ((_ token:String? ,_ error :Error?)-> Void)


protocol AuthenticationServiceProtocol {
    func authorization(with code: String, callBack :@escaping authorizationCallback)
}


class AuthenticationService: AuthenticationServiceProtocol {
    
    let requestManager:RequestManagerProtocol
    let decoder = JSONDecoder()
    
    init(requestManager: RequestManagerProtocol = RequestManager()) {
        self.requestManager = requestManager
    }
    
    func authorization(with code: String, callBack: @escaping authorizationCallback) {
        requestManager.callAPI(requestConvertible: AuthenticationRouter.authorize(code)) { (_ , result, error)  in
            if let data = result , error == nil {
                callBack(String(decoding: data, as: UTF8.self), nil)
            }else {
                callBack(nil, error)
            }
        }
    }
 
}
