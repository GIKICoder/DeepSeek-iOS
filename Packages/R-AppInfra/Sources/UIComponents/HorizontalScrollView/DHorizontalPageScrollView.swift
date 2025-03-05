//
//  DHorizontalPageScrollView.swift
//  AppComponents
//
//  Created by giki on 2024/12/2.
//

import UIKit

public class DHorizontalPageScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    var ignoreView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.panGestureRecognizer.delegate = self
        self.isPagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        // 手势互斥(侧滑返回手势失效后才响应滑动手势)
        // self.panGestureRecognizer.require(toFail: navigationController?.interactivePopGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 首先判断otherGestureRecognizer是不是系统pop手势
        if let otherView = otherGestureRecognizer.view,
           otherView.isKind(of: NSClassFromString("UILayoutContainerView")!) {
            // 再判断系统手势的state是began还是fail，同时判断scrollView的位置是不是正好在最左边
            if otherGestureRecognizer.state == .began && self.contentOffset.x == 0 {
                return true
            }
        }
        return false
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let ignoreView = ignoreView {
            let gesterPoint = gestureRecognizer.location(in: ignoreView)
            // 滑动点在忽略视图的外部，则可滑动。否则不可滑动
            // print("gestureRecognizerShouldBegin \(gesterPoint)")
            if gesterPoint.y < ignoreView.bounds.height {
                return false
            }
        }
        return true
    }
}

