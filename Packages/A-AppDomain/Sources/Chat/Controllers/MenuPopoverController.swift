//
//  MenuPopoverController.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/26.
//

import UIKit
import AppFoundation
import SnapKit

struct PopoverPositionInfo {
    let sourceRect: CGRect
    let arrowDirections: UIPopoverArrowDirection
}

// MARK: - Custom Action Model
struct MenuAction {
    let title: String
    let image: UIImage?
    let handler: () -> Void
}
class TopImageButton: UIButton {
    
    // 定义图片和文字之间的间距
    private let spacing: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        titleLabel?.textAlignment = .center
        imageView?.contentMode = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let imageSize = imageView?.image?.size,
           let titleLabel = titleLabel,
           let titleSize = titleLabel.text?.size(withAttributes: [.font: titleLabel.font ?? .systemFont(ofSize: 13)]) {
            
            // 计算图片位置
            let imageWidth = imageSize.width
            let imageHeight = imageSize.height
            let imageX = (bounds.width - imageWidth) / 2
            let imageY = (bounds.height - (imageHeight + spacing + titleSize.height)) / 2
            imageView?.frame = CGRect(x: imageX, y: imageY, width: imageWidth, height: imageHeight)
            
            // 计算文字位置
            let titleWidth = titleSize.width
            let titleHeight = titleSize.height
            let titleX = (bounds.width - titleWidth) / 2
            let titleY = imageY + imageHeight + spacing
            titleLabel.frame = CGRect(x: titleX, y: titleY, width: titleWidth, height: titleHeight)
        }
    }
    
    // 返回按钮的最小尺寸
    override var intrinsicContentSize: CGSize {
        if let imageSize = imageView?.image?.size,
           let titleSize = titleLabel?.intrinsicContentSize {
            let width = max(imageSize.width, titleSize.width)
            let height = imageSize.height + spacing + titleSize.height
            return CGSize(width: width, height: height)
        }
        return super.intrinsicContentSize
    }
}

class MenuPopoverController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Properties
    private let containerView = UIView()
    private let topButtonsStack = UIStackView()
    private let bottomMenuStack = UIStackView()
    
    var updateSelectAction: (() -> Void)?
    var topMenus: [MenuAction] = []
    var bottomMenus: [MenuAction] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        setupContainerView()
        setupTopButtonsStackIfNeeded()
        setupBottomMenuStack()
    }
    
    private func setupContainerView() {
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTopButtonsStackIfNeeded() {
        guard !topMenus.isEmpty else { return }
        
        topButtonsStack.axis = .horizontal
        topButtonsStack.distribution = .fill  // 改为 fill
        topButtonsStack.spacing = 0
        containerView.addSubview(topButtonsStack)
        
        topButtonsStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(66)
        }
        
        setupTopButtons()
    }
    
    private func setupTopButtons() {
        let buttonWidth = AppF.screenWidth * 0.55 / CGFloat(topMenus.count) // 计算每个按钮的宽度
        
        for (index, action) in topMenus.enumerated() {
            let button = createTopButton(action: action)
            topButtonsStack.addArrangedSubview(button)
            
            // 设置按钮宽度约束
            button.snp.makeConstraints { make in
                make.width.equalTo(buttonWidth)
            }
            
            // 添加除最后一个按钮外的分割线
            if index < topMenus.count - 1 {
                let separator = createVerticalSeparator()
                topButtonsStack.addArrangedSubview(separator)
                
                separator.snp.makeConstraints { make in
                    make.width.equalTo(0.5)
                }
            }
        }
    }
    
    private func createTopButton(action: MenuAction) -> UIButton {
        let button = TopImageButton()
        button.setImage(action.image, for: .normal)
        button.setTitle(action.title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.addTarget(self, action: #selector(topButtonTapped(_:)), for: .touchUpInside)
        button.tag = topButtonsStack.arrangedSubviews.count / 2  // 修改 tag 的计算方式
        
        return button
    }
    
    // 在 setupBottomMenuStack() 方法中添加黑色分割区域
    private func setupBottomMenuStack() {
        bottomMenuStack.axis = .vertical
        bottomMenuStack.spacing = 0
        containerView.addSubview(bottomMenuStack)
        
        // 添加黑色分割区域
        if !topMenus.isEmpty {
            let separator = UIView()
            separator.backgroundColor = UIColor(hex: "E4E6EB")
            containerView.addSubview(separator)
            
            separator.snp.makeConstraints { make in
                make.top.equalTo(topButtonsStack.snp.bottom)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(12)
            }
            
            // 更新 bottomMenuStack 的约束
            bottomMenuStack.snp.makeConstraints { make in
                make.top.equalTo(separator.snp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
        } else {
            bottomMenuStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        setupBottomMenuItems()
    }
    
    // 在 setupBottomMenuItems() 方法中添加分割线
    private func setupBottomMenuItems() {
        for (index, action) in bottomMenus.enumerated() {
            let menuItem = createMenuItem(action: action)
            bottomMenuStack.addArrangedSubview(menuItem)
            
            menuItem.snp.makeConstraints { make in
                make.height.equalTo(48)
            }
            
            // 添加除最后一个按钮外的分割线
            if index < bottomMenus.count - 1 {
                let separator = createHorizontalSeparator()
                bottomMenuStack.addArrangedSubview(separator)
                
                separator.snp.makeConstraints { make in
                    make.height.equalTo(0.5)
                }
            }
        }
    }
    
    
    private func createMenuItem(action: MenuAction) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .clear
        
        let iconImageView = UIImageView(image: action.image)
        iconImageView.contentMode = .scaleAspectFit
        button.addSubview(iconImageView)
        
        let titleLabel = UILabel()
        titleLabel.text = action.title
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .black
        button.addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(13)
            make.centerY.equalToSuperview()
        }
        
        button.tag = bottomMenuStack.arrangedSubviews.count
        button.addTarget(self, action: #selector(menuItemTapped(_:)), for: .touchUpInside)
        
        return button
    }
    
    // 添加创建分割线
    private func createVerticalSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor(hex: "E4E6EB")
        return separator
    }
    
    private func createHorizontalSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor(hex: "E4E6EB")
        return separator
    }
    
    // MARK: - Actions
    @objc private func topButtonTapped(_ sender: UIButton) {
        let action = topMenus[sender.tag]
        action.handler()
        dismiss(animated: true)
    }
    
    @objc private func menuItemTapped(_ sender: UIButton) {
        let action = bottomMenus[sender.tag]
        action.handler()
        dismiss(animated: true)
    }
    
    // MARK: - Static Presenter
    static func present(from sourceView: UIView, with topMenus: [MenuAction], and bottomMenus: [MenuAction], completion: @escaping () -> Void) {
        guard let topVC = UIApplication.getCurrentWindow?.rootViewController else { return }
        
        let popoverVC = MenuPopoverController()
        popoverVC.topMenus = topMenus
        popoverVC.bottomMenus = bottomMenus
        popoverVC.modalPresentationStyle = .popover
        
        var height: CGFloat = 48.0 * CGFloat(bottomMenus.count)
        if !topMenus.isEmpty {
            height += 66.0 + 12
        }
        popoverVC.preferredContentSize = CGSize(width: AppF.screenWidth * 0.55, height: height)
        
        if let popoverPresentationController = popoverVC.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView.bounds
            popoverPresentationController.delegate = popoverVC
            popoverPresentationController.backgroundColor = .clear
            popoverPresentationController.permittedArrowDirections = []
        }
        
        topVC.present(popoverVC, animated: true, completion: completion)
    }
    
    // MARK: - UIPopoverPresentationControllerDelegate
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MenuPopoverController {
    
    static func calculate(
        gestureLocation: CGPoint,
        inView view: UIView,
        popoverSize: CGSize,
        screenSize: CGSize
    ) -> PopoverPositionInfo {
        // 将点击位置转换为屏幕坐标
        let locationInWindow = view.convert(gestureLocation, to: nil)
        
        // 设置常量
        let verticalOffset: CGFloat = 20  // popover 距离点击位置的垂直距离
        let safeMargin: CGFloat = 44      // 距离屏幕边缘的安全距离
        
        // 计算可用空间
        let spaceAbove = locationInWindow.y
        let spaceBelow = screenSize.height - locationInWindow.y
        
        // 计算 sourceRect
        let sourceRect: CGRect
        
        if spaceBelow >= (popoverSize.height + safeMargin) {
            // 在下方显示，点击位置上方 20px
            sourceRect = CGRect(
                x: gestureLocation.x,  // 水平居中
                y: gestureLocation.y + (popoverSize.height / 2) + verticalOffset,           // 下方 20px
                width: 0,
                height: 0
            )
        } else if spaceAbove >= (popoverSize.height + safeMargin) {
            // 在上方显示，点击位置下方 20px
            sourceRect = CGRect(
                x: gestureLocation.x,  // 水平居中
                y: gestureLocation.y - (popoverSize.height / 2) - verticalOffset,           // 上方 20px
                width: 0,
                height: 0
            )
        } else {
            // 如果上下都没有足够空间，则居中显示
            sourceRect = CGRect(
                x: gestureLocation.x,
                y: gestureLocation.y - (popoverSize.height / 2),
                width: 0,
                height: 0
            )
        }
        
        // 始终返回无箭头设置
        return PopoverPositionInfo(
            sourceRect: sourceRect,
            arrowDirections: []  // 不显示箭头
        )
    }
    
}

// MARK: - MenuPopoverController Extension
extension MenuPopoverController {
    static func present(
        from sourceView: UIView,
        at position: CGPoint,
        with topMenus: [MenuAction],
        and bottomMenus: [MenuAction],
        completion: @escaping () -> Void
    ) {
        
        
        guard let topVC = UIApplication.getCurrentWindow?.rootViewController else { return }
        
        let popoverVC = MenuPopoverController()
        popoverVC.topMenus = topMenus
        popoverVC.bottomMenus = bottomMenus
        popoverVC.modalPresentationStyle = .popover
        
        var height: CGFloat = 48.0 * CGFloat(bottomMenus.count)
        if !topMenus.isEmpty {
            height += 66.0 + 12
        }
        let popoverSize = CGSize(width: AppF.screenWidth * 0.55, height: height)
        popoverVC.preferredContentSize = popoverSize
        
        let PositionInfo =  MenuPopoverController.calculate(gestureLocation: position, inView: sourceView, popoverSize: popoverSize, screenSize: UIScreen.main.bounds.size)
        if let popoverPresentationController = popoverVC.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = PositionInfo.sourceRect
            popoverPresentationController.delegate = popoverVC
            popoverPresentationController.backgroundColor = .clear
            popoverPresentationController.permittedArrowDirections = []
        }
        
        topVC.present(popoverVC, animated: true, completion: completion)
    }
}
