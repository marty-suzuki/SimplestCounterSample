//
//  NSObjectProtocol.makeFromNib.swift
//  SimplestCounterSample
//
//  Created by marty-suzuki on 2018/02/06.
//  Copyright © 2018年 marty-suzuki. All rights reserved.
//

import UIKit

extension NSObjectProtocol where Self: UIViewController {
    static func makeFromNib() -> Self {
        return Self(nibName: String(describing: self), bundle: nil)
    }
}
