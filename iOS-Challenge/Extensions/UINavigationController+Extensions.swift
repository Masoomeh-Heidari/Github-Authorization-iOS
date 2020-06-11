//
//  UINavigationController+Extensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

extension Reactive where Base: UIViewController {
    var isOffline: Binder<Bool> {
        return Binder(base) { vc, isOffline in
            isOffline
                ? Banner.show(message: "Internet connection not available!", view: vc.view)
                : Banner.dismiss(view: vc.view)
        }
    }
}

