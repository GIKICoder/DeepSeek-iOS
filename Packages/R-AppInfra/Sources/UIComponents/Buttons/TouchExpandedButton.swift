//
//  TouchExpandedButton.swift
//
//
//  Created by GIKI on 2024/9/10.
//

import Foundation
import UIKit

open class TouchExpandedButton: UIButton {
    public var touchPadding: UIEdgeInsets = .init(top: 5, left: 5, bottom: 5, right: 5)

    override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        let extendedBounds = bounds.inset(by: touchPadding.bInverted())
        return extendedBounds.contains(point)
    }
}

extension UIEdgeInsets {
    func bInverted() -> UIEdgeInsets {
        return UIEdgeInsets(top: -top, left: -left, bottom: -bottom, right: -right)
    }
}
