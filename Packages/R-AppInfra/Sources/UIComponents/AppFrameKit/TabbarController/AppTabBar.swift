//
//  BaseTabBar.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/13.
//

import UIKit
import AppFoundation

// MARK: - BaseTabBar
protocol AppTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: AppTabBar, didSelectItemAt index: Int)
}

open class AppTabBar: UIView {
    weak var delegate: AppTabBarDelegate?
    private var buttons: [AppTabBarButton] = []

    public private(set) var selectedIndex: Int = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = frame.width / CGFloat(buttons.count)
        let buttonHeight = frame.height - safeAreaInsets.bottom
        
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(x: buttonWidth * CGFloat(index),
                                  y: 0,
                                  width: buttonWidth,
                                  height: buttonHeight)
        }
    }
    
    public func didSelectAtIndex(_ index:Int) {
        guard let button = buttons[safe: index] else {
            return
        }
        selectItem(at: index)
        delegate?.tabBar(self, didSelectItemAt: index)
    }
    
    func setupItems(_ items: [TabBarItem]) {
        // 清除现有按钮
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        // 创建新按钮
        for (index, item) in items.enumerated() {
            let button = createTabBarButton(item: item, index: index)
            buttons.append(button)
            addSubview(button)
        }
        
        setNeedsLayout()
    }
    
    private func createTabBarButton(item: TabBarItem, index: Int) -> AppTabBarButton {
        let button = AppTabBarButton()
        button.backgroundColor = .clear
        button.tag = index
        button.title = item.title
        button.image = item.image
        button.selectedImage = item.selectedImage
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func buttonTapped(_ sender: AppTabBarButton) {
        
        selectItem(at: sender.tag)
        delegate?.tabBar(self, didSelectItemAt: sender.tag)
    }
    
    func selectItem(at index: Int) {
        guard let button = buttons[safe: index] else {
            return
        }
        buttons.forEach { $0.isSelected = false }
        button.isSelected = true
        selectedIndex = index
    }
   
}
