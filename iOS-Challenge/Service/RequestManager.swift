//
//  RequestManager.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1398 AP Fariba. All rights reserved.
//


import Foundation
import Alamofire

typealias requestManagerCallBackResult = (Any?,Error?) -> Void

protocol RequestManagerProtocol {
    func callAPI(requestConvertible: URLRequestConvertible, callback: @escaping requestManagerCallBackResult)
}

class RequestManager: RequestManagerProtocol {
    
    
    private let policy = ConnectionLostRetryPolicy(retryLimit: 7)// If network connection losts requests will retried for 10 times
    private var session : Session
    
    init() {
         session = Session(interceptor: policy)
    }
    
    func callAPI(requestConvertible: URLRequestConvertible, callback: @escaping requestManagerCallBackResult) {
        session.request(requestConvertible).validate(statusCode: 200...403).responseJSON { (response) in
                        
            switch response.result {
                
            case .success(_):
                
                do {
                     let response = try response.result.get()
                    callback(response,nil)

                } catch(let error) {
                    callback(nil,error)
                }
          
            case .failure(let error):
                callback(nil,error)
            }
        }
    }
}
