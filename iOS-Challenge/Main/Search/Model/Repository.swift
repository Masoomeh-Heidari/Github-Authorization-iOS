//
//  Repository.swift
//  iOS-Challenge
//
//  Created by Fariba Heidari on 3/21/1399 AP.
//  Copyright © 1399 AP Farshad Mousalou. All rights reserved.
//

import Foundation

struct Repository: Decodable {
    var name: String
    var url: URL

    init(name: String, url: URL) {
        self.name = name
        self.url = url
    }
}
