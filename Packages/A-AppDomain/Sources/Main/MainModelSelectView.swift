//
//  MainModelSelectView.swift
//  AppDomain
//
//  Created by GIKI on 2025/6/4.
//

import UIKit
import AppComponents
import AppInfra
import AppFoundation
import SnapKit
//
//  MainModelSelectView.swift
//  AppDomain
//
//  Created by GIKI on 2025/6/4.
//

import UIKit
import AppComponents
import AppInfra
import AppFoundation
import SnapKit

class MainModelSelectView: UIButton {
    
    // MARK: - UI Components
    private let containerView = UIView()
    private let providerIconImageView = UIImageView()
    private let modelInfoLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - Properties
    var isSelectable: Bool = true {
        didSet {
            updateSelectableState()
            updateLayout()
        }
    }
    
    var providerIcon: UIImage? {
        didSet {
            providerIconImageView.image = providerIcon
            updateLayout()
        }
    }
    
    var modelInfo: String? {
        didSet {
            modelInfoLabel.text = modelInfo
            updateLayout()
        }
    }
    
    // MARK: - Constraints
    private var labelCenterConstraint: Constraint?
    private var labelLeadingConstraint: Constraint?
    private var labelTrailingConstraint: Constraint?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupInteraction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupInteraction()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Container view setup
        containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.separator.cgColor
        containerView.isUserInteractionEnabled = false
        
        // Provider icon setup
        providerIconImageView.contentMode = .scaleAspectFit
        providerIconImageView.layer.cornerRadius = 4
        providerIconImageView.clipsToBounds = true
        providerIconImageView.isHidden = true // 默认隐藏
        
        // Model info label setup
        modelInfoLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        modelInfoLabel.textColor = UIColor.label
        modelInfoLabel.textAlignment = .center // 默认居中
        modelInfoLabel.numberOfLines = 1
        modelInfoLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // Chevron icon setup
        let chevronImage = UIImage(named: "think_arrow_Normal")
        chevronImageView.image = chevronImage
        chevronImageView.tintColor = UIColor.secondaryLabel
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.isHidden = true // 默认隐藏
        
        // Add subviews
        addSubview(containerView)
        containerView.addSubview(providerIconImageView)
        containerView.addSubview(modelInfoLabel)
        containerView.addSubview(chevronImageView)
        
        // Setup semantic content attribute for RTL support
        modelInfoLabel.semanticContentAttribute = .unspecified
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(32)
        }
        
        // Provider icon constraints
        providerIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }
        
        // Chevron icon constraints
        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.size.equalTo(12)
        }
        
        // Label constraints - 初始设置为居中
        setupLabelConstraintsForCenterLayout()
    }
    
    private func setupInteraction() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Layout Management
    private func setupLabelConstraintsForCenterLayout() {
        modelInfoLabel.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        modelInfoLabel.textAlignment = .center
    }
    
    private func setupLabelConstraintsForStackLayout() {
        let hasProviderIcon = providerIcon != nil
        let hasChevron = isSelectable
        
        modelInfoLabel.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            
            if hasProviderIcon {
                make.leading.equalTo(providerIconImageView.snp.trailing).offset(8)
            } else {
                make.leading.equalToSuperview().offset(12)
            }
            
            if hasChevron {
                make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            } else {
                make.trailing.equalToSuperview().offset(-12)
            }
        }
        
        // 根据是否有图标调整文本对齐方式
        if hasProviderIcon || hasChevron {
            modelInfoLabel.textAlignment = .natural
        } else {
            modelInfoLabel.textAlignment = .center
        }
    }
    
    private func updateLayout() {
        let hasProviderIcon = providerIcon != nil
        let hasChevron = isSelectable
        let shouldUseCenterLayout = !hasProviderIcon && !hasChevron
        
        // 更新图标显示状态
        providerIconImageView.isHidden = !hasProviderIcon
        chevronImageView.isHidden = !hasChevron
        
        // 根据是否有图标选择布局方式
        if shouldUseCenterLayout {
            setupLabelConstraintsForCenterLayout()
        } else {
            setupLabelConstraintsForStackLayout()
        }
        
        // 触发布局更新
        setNeedsLayout()
        invalidateIntrinsicContentSize()
        
        // 动画更新布局
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState]) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Public Methods
    func configure(providerIcon: UIImage?, modelInfo: String?, isSelectable: Bool = true) {
        // 批量更新，避免多次布局
        self.providerIcon = providerIcon
        self.modelInfo = modelInfo
        self.isSelectable = isSelectable
        
        // 统一更新布局
        updateLayout()
    }
    
    // MARK: - Private Methods
    private func updateSelectableState() {
        isUserInteractionEnabled = isSelectable
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = self.isSelectable ? 1.0 : 0.7
        }
    }
    
    @objc private func touchDown() {
        guard isSelectable else { return }
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.containerView.backgroundColor = UIColor.systemGray6
        }
    }
    
    @objc private func touchUp() {
        guard isSelectable else { return }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.containerView.transform = .identity
            self.containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        }
    }
    
    // MARK: - Override Methods
    override var intrinsicContentSize: CGSize {
        // 确保 label 有正确的文本
        guard let text = modelInfoLabel.text, !text.isEmpty else {
            return CGSize(width: 80, height: 32) // 最小尺寸
        }
        
        // 计算文本尺寸
        let textSize = (text as NSString).size(withAttributes: [
            .font: modelInfoLabel.font ?? UIFont.systemFont(ofSize: 14)
        ])
        
        let hasProviderIcon = providerIcon != nil
        let hasChevron = isSelectable
        
        let iconWidth: CGFloat = hasProviderIcon ? 16 : 0
        let iconSpacing: CGFloat = hasProviderIcon ? 8 : 0
        let chevronWidth: CGFloat = hasChevron ? 12 : 0
        let chevronSpacing: CGFloat = hasChevron ? 8 : 0
        let horizontalPadding: CGFloat = 24 // 左右各12
        
        let totalWidth = horizontalPadding + iconWidth + iconSpacing + textSize.width + chevronSpacing + chevronWidth
        
        // 设置最小和最大宽度
        let minWidth: CGFloat = 60
        let maxWidth: CGFloat = 220
        let constrainedWidth = max(minWidth, min(totalWidth, maxWidth))
        
        return CGSize(width: constrainedWidth, height: 32)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 动态调整 label 的最大宽度以支持文本截断
        let hasProviderIcon = providerIcon != nil
        let hasChevron = isSelectable
        
        var availableWidth = bounds.width - 24 // 基础 padding
        if hasProviderIcon {
            availableWidth -= 24 // icon + spacing
        }
        if hasChevron {
            availableWidth -= 20 // chevron + spacing
        }
        
        modelInfoLabel.preferredMaxLayoutWidth = max(availableWidth, 40)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update border color for dark mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.layer.borderColor = UIColor.separator.cgColor
        }
    }
}

