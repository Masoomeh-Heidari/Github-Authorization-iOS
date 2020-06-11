//
//  SearchResponse.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/22/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation


class SearchResponse<T:Decodable>: Decodable
{
    var items:[T]
}
