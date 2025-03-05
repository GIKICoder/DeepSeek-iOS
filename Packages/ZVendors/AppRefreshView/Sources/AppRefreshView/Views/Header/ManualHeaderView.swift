//
//  ManualHeaderView.swift
//  HeaderFooterRefreshView
//
//  Created by Vadim Zhydenko on 05.03.2020.
//

import UIKit

@available(iOS 13.0, *)
@MainActor
public class ManualHeaderView: BaseHeaderView {
    
    private lazy var arrowLayer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 0, y: -8))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 5.66, y: 2.34))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: -5.66, y: 2.34))

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.systemGray.cgColor
        layer.lineWidth = 2
        layer.lineCap = .round
        return layer
    }()
    
    override init(height: CGFloat) {
        super.init(height: height)
        layer.addSublayer(arrowLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        arrowLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView) {
        guard refreshingState.isNeedRefreshing && refreshingState.canRefreshing else { return }
        beginRefreshing()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard refreshingState.canBeginRefreshing else { return }
        let value = -(scrollView.contentOffset.y + scrollView.contentInsetTop) / height
        let newRefreshingState = RefreshingState.idleOrInteraction(validate: value)
        guard newRefreshingState != refreshingState else { return }
        refreshingState = newRefreshingState
        alpha = newRefreshingState.value
    }
    
    override func didUpdateState(_ isRefreshing: Bool) {
        super.didUpdateState(isRefreshing)
        arrowLayer.isHidden = isRefreshing
    }

    override func didUpdateProgress(_ progress: CGFloat) {
        let rotation = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        arrowLayer.transform = progress == 1 ? rotation : CATransform3DIdentity
    }
    
}
