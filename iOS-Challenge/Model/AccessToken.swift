//
//  AccessToken.swift
//  iOS-Challenge
//
//  Created by Farshad Mousalou on 2/4/20.
//  Copyright © 2020 Farshad Mousalou. All rights reserved.
//

import Foundation

struct AccessToken: Decodable {
    
    let accessToken: String?
    let tokenType: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope = "scope"
    }
}
