import Foundation
import UIKit
import SnapKit
import AppFoundation
import AppInfra
import IQListKit

public class ChatLoadingCell: ChatContentCell {
    
    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private var animationLayers: [CAShapeLayer] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageView.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        updateLoadingAnimation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // 当视图布局改变时，更新动画
        updateLoadingAnimation()
    }
    
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
        updateLoadingAnimation()
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        // 清理之前的动画层
        cleanupAnimationLayers()
    }
    
    private func cleanupAnimationLayers() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    private func updateLoadingAnimation() {
        // 清理之前的动画
        cleanupAnimationLayers()
        
        // 创建新的动画
        let width: CGFloat = 40  // 动画总宽度
        let height: CGFloat = 15 // 动画高度
        
        // 居中显示动画
        loadingView.frame = CGRect(
            x: (messageView.bounds.width - width) / 2,
            y: (messageView.bounds.height - height) / 2,
            width: width,
            height: height
        )
        
        animationHorizontalDotScaling(loadingView)
    }
    
    private func animationHorizontalDotScaling(_ view: UIView) {
        let width = view.frame.size.width
        let height = view.frame.size.height
        
        let spacing: CGFloat = 3.0
        let radius = (width - spacing * 2) / 3
        let center = CGPoint(x: radius / 2, y: radius / 2)
        let positionY = (height - radius) / 2
        
        let beginTime = CACurrentMediaTime()
        let beginTimes = [0.36, 0.24, 0.12]
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.68, 0.18, 1.08)
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.keyTimes = [0.2, 0.5, 1]
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.values = [1, 0.3, 1]
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        
        let path = UIBezierPath(arcCenter: center, radius: radius / 2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        
        for i in 0..<3 {
            let layer = CAShapeLayer()
            layer.frame = CGRect(x: (radius + spacing) * CGFloat(i), y: positionY+3, width: radius, height: radius)
            layer.path = path.cgPath
            layer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
            
            animation.beginTime = beginTime - beginTimes[i]
            
            layer.add(animation, forKey: "animation")
            view.layer.addSublayer(layer)
            
            // 保存动画层以便后续清理
            animationLayers.append(layer)
        }
    }
}
