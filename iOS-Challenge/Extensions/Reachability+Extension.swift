//
//  Reachability+isConnected.swift
//  iOS-Challenge
//
//  Created by iMamad on 6/6/20.
//  Copyright © 2020 Farshad Mousalou. All rights reserved.
//

import Reachability

extension Reachability {
    var isConnected: Bool {
        if self.connection == .unavailable {
            return false
        }
        return true
    }
}
