//
//  SearchRepoRouter.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/20/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation
import Alamofire

enum SearchRouter  {
    case searchRepo(query: String , page:Int? = 0)
}

extension SearchRouter :Router {
    
    var path: String {
        switch self {
        case .searchRepo:
            return "/search/repositories"

        }
    }
    
    var method: HTTPMethod? {
           switch self {
            case .searchRepo:
                return .get
            }
    }
    
    var params: Parameters? {
          switch self {
          case .searchRepo(let query,let page):
            return ["q":query, "page" :page].compactMapValues{$0}
        }
     }
}
