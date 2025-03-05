//
//  AlertBaseView+Animation.swift
//  DorisKit
//
//  Created by GIKI on 2024/6/24.
//

import UIKit

public enum AlertHideAnimation: Int {
    case fadeOut // 渐隐消失
    case downFadeOut // 向下渐隐
    case bounce // 由大到小消失
    case toBottom
    case toTop
    case toRight
    case toLeft
    case none // 直接消失
    case custom // 自定义
}

public enum AlertShowAnimation: Int {
    case fadeIn // 渐现
    case downFadeIn // 向下渐现
    case bounce // 由小到大弹出
    case fromBottom
    case fromTop
    case fromRight
    case fromLeft
    case none // 直接出现
    case custom // 自定义
}

extension AlertBaseView {
    // MARK: - Show Animations

    @objc dynamic func showAnimationFadeIn() {
        containerView.alpha = 0
        UIView.animate(withDuration: showDuration) {
            self.containerView.alpha = 1
        }
    }

    @objc dynamic func showAnimationDownFadeIn() {
        let upToPoint = containerView.center
        let fromPoint = CGPoint(x: containerView.center.x, y: containerView.center.y - 20)

        let upAnimation = CABasicAnimation(keyPath: "position")
        upAnimation.fromValue = NSValue(cgPoint: fromPoint)
        upAnimation.toValue = NSValue(cgPoint: upToPoint)
        upAnimation.beginTime = 0.0
        upAnimation.duration = showDuration
        upAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.2, 1.0)
        upAnimation.fillMode = .forwards
        upAnimation.isRemovedOnCompletion = false

        let upAlphaAnimation = CABasicAnimation(keyPath: "opacity")
        upAlphaAnimation.fromValue = 0.0
        upAlphaAnimation.toValue = 1.0
        upAlphaAnimation.beginTime = 0.0
        upAlphaAnimation.duration = showDuration
        upAlphaAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.0, 0.0, 0.2, 1.0)
        upAlphaAnimation.fillMode = .forwards
        upAlphaAnimation.isRemovedOnCompletion = false

        let group = CAAnimationGroup()
        group.animations = [upAnimation, upAlphaAnimation]
        group.duration = showDuration
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        containerView.layer.add(group, forKey: "groupAni_showAlert")
    }

    @objc dynamic func showAnimationBounce() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0.01, 1.2, 0.9, 1]
        animation.keyTimes = [0, 0.4, 0.6, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .linear),
            CAMediaTimingFunction(name: .linear),
            CAMediaTimingFunction(name: .easeOut),
        ]
        animation.duration = showDuration
        containerView.layer.add(animation, forKey: "bounce")
    }

    @objc dynamic func showAnimationFromTop() {
        var rect = containerView.frame
        let originalRect = rect
        rect.origin.y = -rect.height
        containerView.frame = rect
        UIView.animate(withDuration: showDuration) {
            self.containerView.frame = originalRect
        }
    }

    @objc dynamic func showAnimationFromBottom() {
        var rect = containerView.frame
        let originalRect = rect
        rect.origin.y = bounds.height
        containerView.frame = rect
        UIView.animate(withDuration: showDuration) {
            self.containerView.frame = originalRect
        }
    }

    @objc dynamic func showAnimationFromRight() {
        var rect = containerView.frame
        let originalRect = rect
        rect.origin.x = bounds.width
        containerView.frame = rect
        UIView.animate(withDuration: showDuration) {
            self.containerView.frame = originalRect
        }
    }

    @objc dynamic func showAnimationFromLeft() {
        var rect = containerView.frame
        let originalRect = rect
        rect.origin.x = -rect.width
        containerView.frame = rect
        UIView.animate(withDuration: showDuration) {
            self.containerView.frame = originalRect
        }
    }

    // MARK: - Hide Animations

    @objc dynamic func hideAnimationFadeOut() {
        UIView.animate(withDuration: hideDuration) {
            self.containerView.alpha = 0
        }
    }

    @objc dynamic func hideAnimationDownFadeOut() {
        let downToPoint = CGPoint(x: containerView.center.x, y: containerView.center.y + 20)

        let downAnimation = CABasicAnimation(keyPath: "position")
        downAnimation.toValue = NSValue(cgPoint: downToPoint)
        downAnimation.duration = 0.2
        downAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.6, 0.0, 1.0, 1.0)
        downAnimation.fillMode = .forwards
        downAnimation.isRemovedOnCompletion = false

        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.toValue = 0.0
        alphaAnimation.duration = 0.2
        alphaAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.6, 0.0, 1.0, 1.0)
        alphaAnimation.fillMode = .forwards
        alphaAnimation.isRemovedOnCompletion = false

        let group = CAAnimationGroup()
        group.animations = [downAnimation, alphaAnimation]
        group.duration = 0.2
        group.isRemovedOnCompletion = false
        group.fillMode = .forwards

        containerView.layer.add(group, forKey: "groupAni_hideAlert")
    }

    @objc dynamic func hideAnimationBounce() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1, 1.2, 0.01]
        animation.keyTimes = [0, 0.4, 1]
        animation.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeOut),
        ]
        animation.duration = hideDuration
        containerView.layer.add(animation, forKey: "bounce")

        containerView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
    }

    @objc dynamic func hideAnimationToBottom() {
        var rect = containerView.frame
        rect.origin.y = bounds.height
        UIView.animate(withDuration: hideDuration, delay: 0, options: .curveEaseIn) {
            self.containerView.frame = rect
        }
    }

    @objc dynamic func hideAnimationToTop() {
        var rect = containerView.frame
        rect.origin.y = -rect.height
        UIView.animate(withDuration: hideDuration, delay: 0, options: .curveEaseIn) {
            self.containerView.frame = rect
        }
    }

    @objc dynamic func hideAnimationToRight() {
        var rect = containerView.frame
        rect.origin.x = bounds.width
        UIView.animate(withDuration: showDuration) {
            self.containerView.frame = rect
        }
    }

    @objc dynamic func hideAnimationToLeft() {
        var rect = containerView.frame
        rect.origin.x = -rect.width
        UIView.animate(withDuration: showDuration) {
            self.containerView.frame = rect
        }
    }
}
