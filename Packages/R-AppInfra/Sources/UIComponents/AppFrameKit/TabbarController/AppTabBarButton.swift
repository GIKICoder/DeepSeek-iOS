//
//  AppTabBarButton.swift
//  AppInfra
//
//  Created by GIKI on 2025/1/13.
//

import UIKit
import AppFoundation

// MARK: - TabBarButtonAppearance
public class TabBarButtonAppearance: NSObject {
    // 图片大小
    public var imageSize: CGSize = CGSize(width: 25, height: 25)
    // 图片和文字间距
    public var spacing: CGFloat = 4
    // 普通状态字体
    public var font: UIFont = .systemFont(ofSize: 12)
    // 选中状态字体
    public var selectedFont: UIFont = .systemFont(ofSize: 12)
    // 普通状态文字颜色
    public var textColor: UIColor = .gray
    // 选中状态文字颜色
    public var selectedTextColor: UIColor = .blue
    
    // 单例模式，用于全局配置
    static public let shared = TabBarButtonAppearance()
    
    private override init() {
        super.init()
    }
}

// MARK: - TabBarButton
public class AppTabBarButton: UIButton {
    
    // MARK: - Public Properties
    var title: String? {
        didSet {
            textLabel.text = title
        }
    }
    
    var image: UIImage? {
        didSet {
            iconView.image = image
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            if isSelected {
                iconView.image = selectedImage
            }
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            updateSelection()
        }
    }
    
    // MARK: - Private Properties
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private var appearance: TabBarButtonAppearance {
        return TabBarButtonAppearance.shared
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupInitialAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupInitialAppearance()
    }
    
    // MARK: - Setup
    private func setupViews() {
        addSubview(iconView)
        addSubview(textLabel)
    }
    
    private func setupInitialAppearance() {
        textLabel.font = appearance.font
        textLabel.textColor = appearance.textColor
    }
    
    // MARK: - Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = appearance.imageSize
        let spacing = appearance.spacing
        
        // 计算imageView的位置
        let imageX = (bounds.width - imageSize.width) / 2
        let totalHeight = imageSize.height + spacing + textLabel.font.lineHeight
        let imageY = (bounds.height - totalHeight) / 2
        
        iconView.frame = CGRect(x: imageX,
                               y: imageY,
                               width: imageSize.width,
                               height: imageSize.height)
        
        // 计算label的位置
        let labelHeight = textLabel.font.lineHeight
        let labelWidth = bounds.width
        let labelY = iconView.frame.maxY + spacing
        
        textLabel.frame = CGRect(x: 0,
                                y: labelY,
                                width: labelWidth,
                                height: labelHeight)
    }
    
    // MARK: - Private Methods
    private func updateSelection() {
        // 更新图片
        if let selectedImage = selectedImage, isSelected {
            iconView.image = selectedImage
        } else {
            iconView.image = image
        }
        
        // 更新字体和颜色
        textLabel.font = isSelected ? appearance.selectedFont : appearance.font
        textLabel.textColor = isSelected ? appearance.selectedTextColor : appearance.textColor
        
    }

}

// MARK: - Usage
extension AppTabBarButton {
    // 配置示例方法
    static func configureAppearance() {
        let appearance = TabBarButtonAppearance.shared
        appearance.imageSize = CGSize(width: 25, height: 25)
        appearance.spacing = 4
        appearance.font = .systemFont(ofSize: 10)
        appearance.selectedFont = .systemFont(ofSize: 10)
        appearance.textColor = .gray
        appearance.selectedTextColor = .blue
    }
}
