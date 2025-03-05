//
//  FullscreenPopGestureRecognizer.swift
//  FullScreenPopGesture
//
//  Created by yuanl on 2024/6/11.
//
//  Copyright (c) 2024 [yuanl]
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/*
private typealias ViewControllerWillAppearInjectBlock = (_ viewController: UIViewController, _ animated: Bool) -> Void

// MARK: - PopGestureRecognizable Protocol

public protocol PopGestureRecognizable: AnyObject {
    var interactivePopDisabled: Bool { get set }
    var prefersNavigationBarHidden: Bool { get set }
    var interactivePopMaxAllowedInitialDistanceToLeftEdge: CGFloat { get set }
    var willAppearInjectBlock: ((_ viewController: UIViewController, _ animated: Bool) -> Void)? { get set }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
}

extension PopGestureRecognizable where Self: UIViewController {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = self.navigationController else { return false }

        if navigationController.viewControllers.count <= 1 {
            return false
        }

        guard let topViewController = navigationController.viewControllers.last else { return false }

        if topViewController.interactivePopDisabled {
            return false
        }

        let beginningLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        let maxAllowedInitialDistance = topViewController.interactivePopMaxAllowedInitialDistanceToLeftEdge
        if maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance {
            return false
        }

        if (navigationController.value(forKey: "_isTransitioning") as? Bool) == true {
            return false
        }

        let translation = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: gestureRecognizer.view) ?? .zero
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if (translation.x * multiplier) <= 0 {
            return false
        }

        return true
    }
}

// MARK: - Associated Keys

private struct AssociatedKeys {
    static var interactivePopDisabled = "interactivePopDisabledKey"
    static var prefersNavigationBarHidden = "prefersNavigationBarHiddenKey"
    static var interactivePopMaxAllowedInitialDistanceToLeftEdge = "interactivePopMaxAllowedInitialDistanceToLeftEdgeKey"
    static var willAppearInjectBlock = "willAppearInjectBlockKey"
}

// MARK: - UIViewController + PopGestureRecognizable

extension UIViewController: PopGestureRecognizable {
    static func performViewControllerSwizzling() {
        let originalViewWillAppearSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledViewWillAppearSelector = #selector(UIViewController.swizzled_viewWillAppear(_:))
        let originalViewWillDisappearSelector = #selector(UIViewController.viewWillDisappear(_:))
        let swizzledViewWillDisappearSelector = #selector(UIViewController.swizzled_viewWillDisappear(_:))

        if let originalViewWillAppearMethod = class_getInstanceMethod(self, originalViewWillAppearSelector),
           let swizzledViewWillAppearMethod = class_getInstanceMethod(self, swizzledViewWillAppearSelector) {
            method_exchangeImplementations(originalViewWillAppearMethod, swizzledViewWillAppearMethod)
        }

        if let originalViewWillDisappearMethod = class_getInstanceMethod(self, originalViewWillDisappearSelector),
           let swizzledViewWillDisappearMethod = class_getInstanceMethod(self, swizzledViewWillDisappearSelector) {
            method_exchangeImplementations(originalViewWillDisappearMethod, swizzledViewWillDisappearMethod)
        }
    }

    @objc func swizzled_viewWillAppear(_ animated: Bool) {
        self.swizzled_viewWillAppear(animated)
        self.willAppearInjectBlock?(self, animated)
    }

    @objc func swizzled_viewWillDisappear(_ animated: Bool) {
        self.swizzled_viewWillDisappear(animated)
        DispatchQueue.main.async {
            guard let viewController = self.navigationController?.viewControllers.last else { return }
            if !viewController.prefersNavigationBarHidden {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
    }

    public var interactivePopDisabled: Bool {
        get {
                return objc_getAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.interactivePopDisabled) {
                    $0
                }) as? Bool ?? false
            }
        set {
            objc_setAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.interactivePopDisabled) {
                $0
            }, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var prefersNavigationBarHidden: Bool {
        get {
            return objc_getAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.prefersNavigationBarHidden) {
                $0
            }) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.prefersNavigationBarHidden) {
                $0
            }, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var interactivePopMaxAllowedInitialDistanceToLeftEdge: CGFloat {
        get {
            return objc_getAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.interactivePopMaxAllowedInitialDistanceToLeftEdge) {
                $0
            }) as? CGFloat ?? 0
        }
        set {
            objc_setAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.interactivePopMaxAllowedInitialDistanceToLeftEdge) {
                $0
            }, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var willAppearInjectBlock: ((_ viewController: UIViewController, _ animated: Bool) -> Void)? {
        get {
            return objc_getAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.willAppearInjectBlock) {
                $0
            }) as? ((_ viewController: UIViewController, _ animated: Bool) -> Void)
        }
        set {
            objc_setAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.willAppearInjectBlock) {
                $0
            }, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

// MARK: - FullscreenPopGestureRecognizerDelegate

class FullscreenPopGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {

    weak var navigationController: UINavigationController?

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = navigationController else { return false }

        if navigationController.viewControllers.count <= 1 {
            return false
        }

        guard let topViewController = navigationController.viewControllers.last else { return false }

        if topViewController.interactivePopDisabled {
            return false
        }

        let beginningLocation = gestureRecognizer.location(in: gestureRecognizer.view)
        let maxAllowedInitialDistance = topViewController.interactivePopMaxAllowedInitialDistanceToLeftEdge
        if maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance {
            return false
        }

        if (navigationController.value(forKey: "_isTransitioning") as? Bool) == true {
            return false
        }

        let translation = (gestureRecognizer as? UIPanGestureRecognizer)?.translation(in: gestureRecognizer.view) ?? .zero
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if (translation.x * multiplier) <= 0 {
            return false
        }

        return true
    }
}

// MARK: - UINavigationController + Fullscreen Pop Gesture

extension UINavigationController {

    private struct AssociatedKeys {
        static var fullscreenPopGestureRecognizerDelegate = "fullscreenPopGestureRecognizerDelegateKey"
        static var fullscreenPopGestureRecognizer = "fullscreenPopGestureRecognizerKey"
        static var viewControllerBasedNavigationBarAppearanceEnabled = "viewControllerBasedNavigationBarAppearanceEnabledKey"
    }

    private var popGestureRecognizerDelegate: FullscreenPopGestureRecognizerDelegate {
        if let delegate = objc_getAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.fullscreenPopGestureRecognizerDelegate) {
            $0
        }) as? FullscreenPopGestureRecognizerDelegate {
            return delegate
        } else {
            let delegate = FullscreenPopGestureRecognizerDelegate()
            delegate.navigationController = self
            objc_setAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.fullscreenPopGestureRecognizerDelegate) {
                $0
            }, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return delegate
        }
    }

    public var fullscreenPopGestureRecognizer: UIPanGestureRecognizer {
        if let recognizer = objc_getAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.fullscreenPopGestureRecognizer) {
            $0
        }) as? UIPanGestureRecognizer {
            return recognizer
        } else {
            let recognizer = UIPanGestureRecognizer()
            recognizer.maximumNumberOfTouches = 1
            recognizer.delegate = self.popGestureRecognizerDelegate
            objc_setAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.fullscreenPopGestureRecognizer) {
                $0
            }, recognizer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return recognizer
        }
    }

    var viewControllerBasedNavigationBarAppearanceEnabled: Bool {
        get {
            return objc_getAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.viewControllerBasedNavigationBarAppearanceEnabled) {
                $0
            }) as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(self, withUnsafePointer(to: &AssociatedKeys.viewControllerBasedNavigationBarAppearanceEnabled) {
                $0
            }, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // Swizzling Methods
    private static let swizzleViewControllerImplementation: Void = {
        swizzlePushMethod()
        UIViewController.performViewControllerSwizzling()
    }()

    open override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationController.swizzleViewControllerImplementation
    }

    private static func swizzlePushMethod() {
        let originalSelector = #selector(UINavigationController.pushViewController(_:animated:))
        let swizzledSelector = #selector(UINavigationController.swizzled_pushViewController(_:animated:))

        if let originalMethod = class_getInstanceMethod(UINavigationController.self, originalSelector),
           let swizzledMethod = class_getInstanceMethod(UINavigationController.self, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    @objc func swizzled_pushViewController(_ viewController: UIViewController, animated: Bool) {
        // Add full screen pop gesture recognizer
        if !self.interactivePopGestureRecognizer!.view!.gestureRecognizers!.contains(self.fullscreenPopGestureRecognizer) {
            self.interactivePopGestureRecognizer!.view!.addGestureRecognizer(self.fullscreenPopGestureRecognizer)

            // Get the internal gesture recognizer target and action
            let internalTargets = self.interactivePopGestureRecognizer?.value(forKey: "targets") as? [NSObject]
            let internalTarget = internalTargets?.first?.value(forKey: "target")
            let internalAction = Selector(("handleNavigationTransition:"))

            self.fullscreenPopGestureRecognizer.addTarget(internalTarget!, action: internalAction)

            // Disable the default gesture
            self.interactivePopGestureRecognizer?.isEnabled = false
        }

        // Setup the appearance if needed
        self.setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController: viewController)

        // Push the view controller
        if !self.viewControllers.contains(viewController) {
            self.swizzled_pushViewController(viewController, animated: animated)
        }
    }

    private func setupViewControllerBasedNavigationBarAppearanceIfNeeded(viewController: UIViewController) {
        if !self.viewControllerBasedNavigationBarAppearanceEnabled {
            return
        }

        let willAppearBlock: ViewControllerWillAppearInjectBlock = { [weak self] vc, animated in
            guard let strongSelf = self else { return }
            strongSelf.setNavigationBarHidden(vc.prefersNavigationBarHidden, animated: animated)
        }

        viewController.willAppearInjectBlock = willAppearBlock

        let disappearingViewController = self.viewControllers.last
        if let disappearingViewController = disappearingViewController,
           disappearingViewController.willAppearInjectBlock == nil {
            disappearingViewController.willAppearInjectBlock = willAppearBlock
        }
    }
}
*/
