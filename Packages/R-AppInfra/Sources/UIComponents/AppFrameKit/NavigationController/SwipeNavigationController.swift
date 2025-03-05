//
//  SwipeNavigationController.swift
//
//
//  Created by GIKI on 2024/9/21.
//

import Hero
import UIKit

public class SwipeNavigationController: UINavigationController {
    public var edgePanGesture: UIScreenEdgePanGestureRecognizer?
    
    convenience init(rootViewController: UIViewController, animationType: HeroDefaultAnimationType) {
        self.init(rootViewController: rootViewController)
        initializeSN(animationType)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        initializeSN()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeSN()
    }
    
    private func initializeSN(_ modalAnimationType: HeroDefaultAnimationType = .autoReverse(presenting: .pageIn(direction: .up))) {
        modalPresentationStyle = .fullScreen
        hero.isEnabled = true
        hero.modalAnimationType = modalAnimationType
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // 禁用默认的侧滑返回手势
        interactivePopGestureRecognizer?.isEnabled = false
        
        // 创建新的屏幕边缘手势
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
        // 根据当前的界面布局方向设置边缘
        if isRightToLeftLayout() {
            edgePan.edges = .right
        } else {
            edgePan.edges = .left
        }
        view.addGestureRecognizer(edgePan)
        edgePanGesture = edgePan
    }
    
    // 判断当前的界面布局方向是否为RTL
    func isRightToLeftLayout() -> Bool {
        return UIView.userInterfaceLayoutDirection(for: view.semanticContentAttribute) == .rightToLeft
    }
    // MARK: - Gesture Handler
    
    @objc private func handleEdgePan(_ gr: UIScreenEdgePanGestureRecognizer) {
        let translation = gr.translation(in: view)
        let velocity = gr.velocity(in: view)
        
        // 根据布局方向调整 translation.x 和 velocity.x
        let isRTL = isRightToLeftLayout()
        let adjustedTranslationX = isRTL ? -translation.x : translation.x
        let adjustedVelocityX = isRTL ? -velocity.x : velocity.x
        
        // 计算手势进度
        let progress = adjustedTranslationX / view.bounds.width
        
        switch gr.state {
        case .began:
            // 开始手势时，可以根据需要启动交互式转场
            if let rootVC = topViewController {
                rootVC.dismiss(animated: true, completion: nil)
            } else {
                dismiss(animated: true, completion: nil)
            }
        case .changed:
            // 更新Hero的转场进度
            Hero.shared.update(progress)
        default:
            // 根据进度和速度决定是否完成或取消转场
            if (progress + (adjustedVelocityX / view.bounds.width)) > 0.2 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
}
