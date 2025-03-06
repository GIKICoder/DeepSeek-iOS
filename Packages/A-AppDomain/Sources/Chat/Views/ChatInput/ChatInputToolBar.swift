//
//  ChatInputToolBar.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/27.
//

import UIKit
import SnapKit
import AppInfra
import AppFoundation


public class ChatInputToolBar: UIView {
    
    // MARK: - Public Properties
    
    /// TextView 配置
    public struct TextViewConfig {
        var minHeight: CGFloat = 36
        var maxLines: Int = 5
        var minLines: Int = 1
        var maxCount: Int = 200
        var placeholder: String = NSLocalizedString("给DeepSeek发送消息", comment: "")
        var placeholderColor: UIColor = .lightGray
    }
    
    public var contentEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12+42, right: 16) {
        didSet {
            containerView.snp.updateConstraints { make in
                make.edges.equalToSuperview().inset(contentEdgeInsets)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    public var textViewConfig: TextViewConfig = TextViewConfig() {
        didSet {
            updateTextViewConfig()
            invalidateIntrinsicContentSize()
        }
    }
    
    public var heightDidChange: (() -> Void)?
    
    // MARK: - UI Components
    
    public let leftStackView = UIStackView()
    public let rightStackView = UIStackView()
    public let growingTextView = NextGrowingTextView()
    
    // 新增的 containerView
    private let containerView = UIView()
    
    private let stackContainerView = UIView()
    
    // MARK: - Private Properties
    
    private let defaultStackViewWidth: CGFloat = 42
    
    private let defaultContainerViewHeight: CGFloat = 48
    private let defaultStackContainerViewHeight: CGFloat = 42
    
    private var textViewHeight: CGFloat = 32
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGrowingTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    public func resetToolbar() {
        growingTextView.textView.text = nil
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        backgroundColor = .white
        
        // 设置 containerView
        addSubview(containerView)
        containerView.backgroundColor = UIColor(hex: "F2F4F7")
        containerView.layer.cornerRadius = 24
        containerView.clipsToBounds = true
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentEdgeInsets)
            make.height.greaterThanOrEqualTo(defaultContainerViewHeight) // 初始高度为 48
        }
        
        addSubview(stackContainerView)
        stackContainerView.backgroundColor = .clear
        stackContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(defaultStackContainerViewHeight)
            make.top.equalTo(containerView.snp.bottom).offset(8)
        }
        setupStackViews()
    }
    
    
    private func setupStackViews() {

        containerView.addSubview(growingTextView)
        // 设置 growingTextView 的约束
        growingTextView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        // 配置左侧和右侧的 StackView
        [leftStackView, rightStackView].forEach { stackView in
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.spacing = 10
            stackView.distribution = .fill
            stackView.isHidden = false  // 初始隐藏，等有内容时再显示
            // 设置布局边距
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        stackContainerView.addSubview(leftStackView)
        stackContainerView.addSubview(rightStackView)
        // 设置 leftStackView 的约束
        leftStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-10)
            // 让 StackView 根据内容自适应大小
            make.height.greaterThanOrEqualTo(0)
        }
        
        // 设置 rightStackView 的约束
        rightStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
            // 让 StackView 根据内容自适应大小
            make.height.greaterThanOrEqualTo(0)
        }
    }
    
    
    private func updateTextViewConfig() {
        growingTextView.configuration.minLines = textViewConfig.minLines
        growingTextView.configuration.maxLines = textViewConfig.maxLines
        growingTextView.placeholderLabel.text = textViewConfig.placeholder
        growingTextView.placeholderLabel.textColor = textViewConfig.placeholderColor
    }
    
    private func setupGrowingTextView() {
        updateTextViewConfig()
        growingTextView.actionHandler = { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .didChangeHeight(let newHeight):
                self.textViewHeight = newHeight
                logUI("inputoolbar didChangeHeight: \(newHeight)")
                self.invalidateIntrinsicContentSize()
                self.heightDidChange?()
            default:
                break
            }
        }
    }
    
    
    // MARK: - Override Methods
    
    public override var intrinsicContentSize: CGSize {
        // 计算 growingTextView 的高度
        let textViewHeight = self.textViewHeight
        logUI("inputoolbar textViewHeight: \(textViewHeight)")
        // 计算 containerView 的高度（顶部和底部内边距各 12，加上 textView 的高度）
        let containerHeight = max(defaultContainerViewHeight, textViewHeight + 16) // 16 为上下各8的间距
        logUI("inputoolbar containerHeight: \(containerHeight)")
        // 总高度为 containerView 的高度 + contentEdgeInsets 上下
        let totalHeight = contentEdgeInsets.top + containerHeight + contentEdgeInsets.bottom
        logUI("inputoolbar totalHeight: \(totalHeight)")
        return CGSize(width: UIView.noIntrinsicMetric, height: totalHeight)
    }
    
}

// MARK: - ChatInputToolBar Extension for Button Management

public extension ChatInputToolBar {
    func addLeftItemView(_ view: UIView) {
        // 检查按钮是否已经设置了宽度约束
        if !view.constraints.contains(where: { $0.firstAttribute == .width }) {
            view.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: defaultStackViewWidth, height: defaultStackViewWidth))
            }
        }
        leftStackView.addArrangedSubview(view)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func addRightItemView(_ view: UIView) {
        // 检查按钮是否已经设置了宽度约束
        if !view.constraints.contains(where: { $0.firstAttribute == .width }) {
            view.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: defaultStackViewWidth, height: defaultStackViewWidth))
            }
        }
        rightStackView.addArrangedSubview(view)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func removeLeftItemView(_ view: UIView) {
        leftStackView.removeArrangedSubview(view)
        view.removeFromSuperview()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func removeRightItemView(_ view: UIView) {
        rightStackView.removeArrangedSubview(view)
        view.removeFromSuperview()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func removeAllLeftViews() {
        leftStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func removeAllRightViews() {
        rightStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        setNeedsLayout()
        layoutIfNeeded()
    }
}
