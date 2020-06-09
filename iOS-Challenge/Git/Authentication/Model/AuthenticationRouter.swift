//
//  AuthenticationRouter.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1398 AP Fariba. All rights reserved.
//

import Foundation
import Alamofire

enum AuthenticationRouter  {
    case authorize(_ code: String)
}

extension AuthenticationRouter :Router {
    
    var path: String {
        switch self {
        case .authorize:
            return "login/oauth/authorize"

        }
    }
    
    var method: HTTPMethod? {
           switch self {
            case .authorize:
                return .post
            }
    }
    
    var params: Parameters? {
          switch self {
          case .authorize(let code):
            return ["client_id": API.CLIENT_ID,"code": code, "state": 0, "redirect_uri": API.REDIRECT_URI,"client_secret": API.CLIENT_SECRET]
            }
     }
}
