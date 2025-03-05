//
//  File.swift
//  
//
//  Created by GIKI on 2025/1/2.
//

import Foundation
import UIKit
import SnapKit

// MARK: - 空状态配置模型
public struct EmptyStateConfig {
    let icon: UIImage?
    let text: String
    let iconSize: CGSize
    let textColor: UIColor
    let textFont: UIFont
    let spacing: CGFloat
    let topOffset: CGFloat  // 添加顶部偏移量配置
    
    public init(
        icon: UIImage? = nil,
        text: String = "暂无数据",
        iconSize: CGSize = CGSize(width: 100, height: 100),
        textColor: UIColor = .gray,
        textFont: UIFont = .systemFont(ofSize: 14),
        spacing: CGFloat = 20,
        topOffset: CGFloat = 0  // 默认顶部偏移量为0
    ) {
        self.icon = icon
        self.text = text
        self.iconSize = iconSize
        self.textColor = textColor
        self.textFont = textFont
        self.spacing = spacing
        self.topOffset = topOffset
    }
}

// MARK: - UIView扩展
public extension UIView {
    
    private struct AssociatedKeys {
        static var emptyStateView = "emptyStateView"
    }
    
    // 存储空状态视图的属性
    private var emptyStateView: UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.emptyStateView) as? UIView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.emptyStateView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 显示空状态视图
    func showEmptyState(config: EmptyStateConfig = EmptyStateConfig()) {
        removeEmptyState()
        
        // 创建容器视图
        let containerView = UIView()
        containerView.backgroundColor = .clear
        // 将容器视图添加到当前视图
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.emptyStateView = containerView
        
        // 创建垂直堆栈视图
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = config.spacing
        
        // 添加图标（如果有）
        if let icon = config.icon {
            let imageView = UIImageView(image: icon)
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)
            
            imageView.snp.makeConstraints { make in
                make.size.equalTo(config.iconSize)
            }
        }
        
        // 添加文本标签
        let label = UILabel()
        label.text = config.text
        label.textColor = config.textColor
        label.font = config.textFont
        label.textAlignment = .center
        label.numberOfLines = 0
        stackView.addArrangedSubview(label)
        
        // 将堆栈视图添加到容器中
        containerView.addSubview(stackView)
        // 更新stackView的约束，支持顶部偏移
        stackView.snp.makeConstraints { make in
            // 如果设置了顶部偏移，优先使用顶部对齐
            if config.topOffset > 0 {
                make.top.equalToSuperview().offset(config.topOffset)
            } else {
                make.centerY.equalToSuperview()
            }
            
            make.centerX.equalToSuperview()  // 水平居中
//            make.leading.greaterThanOrEqualToSuperview().offset(20)
//            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
    }
    
    // 移除空状态视图
    func removeEmptyState() {
        emptyStateView?.removeFromSuperview()
        emptyStateView = nil
    }
}
