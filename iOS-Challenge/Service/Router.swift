//
//  Router.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1398 AP Fariba. All rights reserved.
//


import Foundation
import Alamofire

public typealias Body = [String: Any]

protocol Router:URLRequestConvertible {
    var baseURLString :String? { get }
    var method: HTTPMethod? { get }
    var path: String {get }
    var headers: HTTPHeaders? { get }
    var encoding: ParameterEncoding? { get }
    var params: Parameters? { get }
    var body: Body? { get }
    func asURLRequest() throws -> URLRequest
}

extension Router {
    var baseURLString: String? {
        return  API.BASE_URL
    }
    
    //add Rout method here
    var method: HTTPMethod? {
        return .post
    }
    
    //set APIs'Rout for each case
    var path: String {
        return ""
    }
    
    var headers: HTTPHeaders? {
        return ["Content-Type":"application/json"]
     }
    
    // set encoding for each APIs
    var encoding: ParameterEncoding? {
        return URLEncoding.queryString
    }
    
    
    
    // return each case parameters
    var params: Parameters? {
        return [:]
    }
    
    var body: Body? {
           return [:]
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: self.baseURLString!.appending(path))
        
        let urlRequest = URLRequest(url: url!)
        
        var encodedURLRequest = try URLEncodedFormParameterEncoder.default.encode((params as! [String:String]) ,into: urlRequest)
        
        encodedURLRequest.httpMethod = method?.rawValue
        encodedURLRequest.allHTTPHeaderFields = headers?.dictionary
        
        return encodedURLRequest
    }
}
