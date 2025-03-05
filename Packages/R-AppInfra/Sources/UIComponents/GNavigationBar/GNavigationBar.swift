//
//  GNavigationBar.swift
//
//
//  Created by GIKI on 2024/6/24.
//

import SnapKit
import UIKit
import AppFoundation

public let NavigationItemSize = CGSize(width: 24, height: 24)

@MainActor
open class NavigationItem {
    public let view: UIView
    public var size: CGSize
    
    public init(view: UIView, size: CGSize? = nil) {
        self.view = view
        self.size = size ?? NavigationItemSize
        self.view.frame.size = self.size
    }
    
    public convenience init(image: UIImage?, highlightedImage: UIImage? = nil, size: CGSize? = nil, target: Any?, action: Selector?) {
        let button = TouchExpandedButton(type: .custom)
        button.touchPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setImage(image, for: .normal)
        button.setImage(highlightedImage, for: .highlighted)
        if let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        self.init(view: button, size: size)
    }
    
    public convenience init(title: String, size: CGSize? = nil, color:UIColor = .black, font:UIFont = .systemFont(ofSize: 16), target: Any?, action: Selector?) {
        let button = TouchExpandedButton(type: .custom)
        button.touchPadding = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setTitle(title, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = font
        if let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        self.init(view: button, size: size)
    }
}

public extension GNavigationBar {
    @discardableResult
    func addLeft(_ image: UIImage?,
                 size: CGSize = NavigationItemSize,
                 target: AnyObject? = nil,
                 action: Selector? = nil) -> NavigationItem
    {
        let item = NavigationItem(image: image, size: size, target: target, action: action)
        addLeftItem(item)
        return item
    }
    
    @discardableResult
    func addRight(_ image: UIImage?,
                  size: CGSize = NavigationItemSize,
                  target: AnyObject? = nil,
                  action: Selector? = nil) -> NavigationItem
    {
        let item = NavigationItem(image: image, size: size, target: target, action: action)
        addRightItem(item)
        return item
    }
}

@MainActor
open class GNavigationBar: UIView {
    // MARK: - Properties
    
    private var statusBarHeight: CGFloat {
        return getStatusBarHeight()
    }
    
    public var customHeight: CGFloat = 54.0
    public var leftPadding: CGFloat = 20.0
    public var rightPadding: CGFloat = 20.0
    public var itemSpacing: CGFloat = 16.0
    
    public let statusBarView = UIView()
    public let contentView = UIView()
    public let leftStackView = UIStackView()
    public let centerView = UIView()
    public let rightStackView = UIStackView()
    
    public let centerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let bottomLine: UIView = {
        let line = UIView()
        line.backgroundColor = .lightGray
        line.isHidden = true
        return line
    }()
    
    private var ignoreStatusbar = false
    
    // MARK: - Initialization
    
    public init(
        height: CGFloat = 54.0,
        leftPadding: CGFloat = 20.0,
        rightPadding: CGFloat = 20.0,
        itemSpacing: CGFloat = 16.0,
        ignoreStatusbar: Bool = false
    ) {
        super.init(frame: .zero)
        customHeight = height
        self.leftPadding = leftPadding
        self.rightPadding = rightPadding
        
        self.itemSpacing = itemSpacing
        var totalHeight = statusBarHeight + customHeight
        if ignoreStatusbar {
            totalHeight = customHeight
        }
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: totalHeight)
        backgroundColor = .white
        setupViews()
    }
    
    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        updateLayout() // 更新布局
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        addSubview(statusBarView)
        addSubview(contentView)
        addSubview(bottomLine)
        
        contentView.addSubview(leftStackView)
        contentView.addSubview(centerView)
        contentView.addSubview(rightStackView)
        
        centerView.addSubview(centerLabel)
        
        setupConstraints()
        setupStackViews()
    }
    
    private func setupConstraints() {
        statusBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(statusBarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(customHeight)
        }
        
        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(leftPadding)
            make.height.centerY.equalToSuperview()
        }
        
        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-rightPadding)
            make.height.centerY.equalToSuperview()
        }
        
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview()
            make.leading.greaterThanOrEqualTo(leftStackView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(rightStackView.snp.leading).offset(-12)
            // 移除宽度约束，让 UIStackView 自行管理
        }
        
        centerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bottomLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    private func setupStackViews() {
        leftStackView.axis = .horizontal
        leftStackView.spacing = itemSpacing
        leftStackView.alignment = .center
        leftStackView.distribution = .equalSpacing  // 更改为 .equalSpacing
        
        rightStackView.axis = .horizontal
        rightStackView.spacing = itemSpacing
        rightStackView.alignment = .center
        rightStackView.distribution = .equalSpacing  // 更改为 .equalSpacing
        // 从右到左排列
        rightStackView.semanticContentAttribute = .forceRightToLeft
    }
    
    private func updateLayout() {
    
        var totalHeight = statusBarHeight + customHeight
        if ignoreStatusbar {
            totalHeight = customHeight
        }
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: totalHeight)
        statusBarView.snp.updateConstraints { make in
            make.height.equalTo(statusBarHeight)
        }
    }
    // MARK: - Public Methods
    
    @discardableResult
    public func addLeftItem(_ item: NavigationItem) -> Self {
        leftStackView.addArrangedSubview(item.view)
        item.view.snp.makeConstraints { make in
            make.width.equalTo(item.size.width)
            make.height.equalTo(item.size.height)
        }
        return self
    }
    
    @discardableResult
    public func addRightItem(_ item: NavigationItem) -> Self {
        rightStackView.addArrangedSubview(item.view)
        item.view.snp.makeConstraints { make in
            make.width.equalTo(item.size.width)
            make.height.equalTo(item.size.height)
        }
        return self
    }
    
    public func setCenterItem(_ item: NavigationItem) {
        centerView.subviews.forEach { $0.removeFromSuperview() }
        centerView.addSubview(item.view)
        item.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(item.size.width)
            make.height.equalTo(item.size.height)
        }
    }
    
    public func setTitle(_ title: String) {
        centerLabel.text = title
    }
    
    public func setBackgroundColor(_ color: UIColor) {
        statusBarView.backgroundColor = color
        contentView.backgroundColor = color
        backgroundColor = color
    }
    
    public func setBottomLineHidden(_ isHidden: Bool) {
        bottomLine.isHidden = isHidden
    }
    
    public func setBottomLineColor(_ color: UIColor) {
        bottomLine.backgroundColor = color
    }
    
    public func updateStatusBarVisibility() {
        let height = getStatusBarHeight()
        statusBarView.isHidden = height == 0
        statusBarView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    @discardableResult
    public func removeItem(_ item: NavigationItem) -> Self {
        if let view = item.view.superview as? UIStackView {
            view.removeArrangedSubview(item.view)
            item.view.removeFromSuperview()
            // 更新布局
            setNeedsLayout()
            layoutIfNeeded()
        }
        return self
    }
    
    @discardableResult
    public func replaceItem(_ oldItem: NavigationItem, with newItem: NavigationItem) -> Self {
        if let view = oldItem.view.superview as? UIStackView {
            let index = view.arrangedSubviews.firstIndex(of: oldItem.view)
            removeItem(oldItem)
            if let index = index {
                view.insertArrangedSubview(newItem.view, at: index)
                newItem.view.snp.makeConstraints { make in
                    make.width.equalTo(newItem.size.width)
                    make.height.equalTo(newItem.size.height)
                }
            }
        }
        // 更新布局
        setNeedsLayout()
        layoutIfNeeded()
        return self
    }
    
    // MARK: - Private Methods
    
    private func getStatusBarHeight() -> CGFloat {
        // 获取主窗口
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            return window.safeAreaInsets.top
        }
        return 22
    }
}
