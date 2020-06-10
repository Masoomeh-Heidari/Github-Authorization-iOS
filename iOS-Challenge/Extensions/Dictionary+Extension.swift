//
//  Dictionary_extension.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/21/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation

extension Dictionary {
    var queryString :String {
        get {
            var components = URLComponents()
            components.queryItems = self.compactMap { (key, value)  in
                return URLQueryItem(name: key as! String, value: value  as? String)
             }
               return (components.url?.absoluteString)!
        }
    }
}
