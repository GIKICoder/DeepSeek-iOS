//
//  ChatInputButton.swift
//  AppDomain
//
//  Created by GIKI on 2025/3/6.
//

import UIKit
import SnapKit

class ChatInputButton: UIControl {
    
    // MARK: - Properties
    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    private let selectedColor = UIColor(hex: "5991df")
    private let defaultBackgroundColor = UIColor(hex: "f5f5f5")
    private let selectedBackgroundColor = UIColor(hex: "e5effe").withAlphaComponent(0.6)
    
    override var isSelected: Bool {
        didSet {
            updateSelectedState()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    
    // MARK: - Public Methods
    func configure(icon: UIImage?, title: String) {
        iconView.image = icon
        titleLabel.text = title
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        // 设置默认背景色和圆角
        backgroundColor = defaultBackgroundColor
        layer.cornerRadius = 14
        
        // 添加子视图
        addSubview(iconView)
        addSubview(titleLabel)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8) // 添加左边距
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-8) // 添加右边距
        }
    }
    
    private func updateSelectedState() {
        // 更新文字和图标颜色
        titleLabel.textColor = isSelected ? selectedColor : .black
        if let image = iconView.image {
            iconView.image = isSelected ? image.withTintColor(selectedColor) : image.withTintColor(.black)
        }
        
        // 更新背景色
        backgroundColor = isSelected ? selectedBackgroundColor : defaultBackgroundColor
    }
}
