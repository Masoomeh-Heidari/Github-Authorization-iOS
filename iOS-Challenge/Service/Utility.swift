//
//  Example.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//


import UIKit
import Toast_Swift

typealias Image = UIImage

let MB = 1024 * 1024

func createError(_ error: String, location: String = "\(#file):\(#line)") -> NSError {
    return NSError(domain: "challengeError", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(location): \(error)"])
}

extension String {
    func toFloat() -> Float? {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.floatValue
    }
    
    func toDouble() -> Double? {
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.doubleValue
    }
}

class Banner {
    
    static var style = ToastStyle()
    
    static func show(message: String, view:UIView){
        style.messageColor = UIColor(red: 1.0, green: 0.6, blue: 0.6, alpha: 1.0)
        view.makeToast(message, duration: 3.0, position: .top, style: style)
    }
    
    static func dismiss(view: UIView){
        view.hideAllToasts()
    }
    
}
