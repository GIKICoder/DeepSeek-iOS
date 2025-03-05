//
//  SwipeNavigationController.swift
//
//
//  Created by GIKI on 2024/9/21.
//

import UIKit

public final class AppNavigationController: UINavigationController {
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
        view.backgroundColor = .black
        interactivePopGestureRecognizer?.delegate = self
    }
}

extension AppNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        if (topViewController as? BaseViewController)?.preferredDisablePanToPop == true {
            false
        } else {
            viewControllers.count > 1
        }
    }
}
