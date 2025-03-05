//
//  UIEdgeInsets.swift
//  AppFoundation
//
//  Created by GIKI on 2025/1/10.
//

import UIKit

extension UIEdgeInsets {
    ///  Easier initialization of UIEdgeInsets
    public init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}
