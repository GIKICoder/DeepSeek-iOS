//
//  ChatInputToolView.swift
//  DListKit
//
//  Created by GIKI on 2025/1/5.
//

import UIKit
import SnapKit
import AppInfra
import AppFoundation
import Combine

// MARK: - Input State Enum
public enum ChatInputToolViewState {
    case systemKeyboardWillShow
    case systemKeyboardWillHide
    case customKeyboardWillShow
    case customKeyboardWillHide
    case inputBarHeightDidChange
    
    var isShowingKeyboard: Bool {
        switch self {
        case .systemKeyboardWillShow, .customKeyboardWillShow:
            return true
        default:
            return false
        }
    }
}

// MARK: - Delegate Protocol
public protocol ChatInputToolViewDelegate: AnyObject {
    func chatInputToolView(_ inputToolView: ChatInputToolView, didChangeInputBarTopOffset offset: CGFloat, state: ChatInputToolViewState)
    
    func chatInputToolView(_ inputToolView: ChatInputToolView, didReturnSend text: String?, imageUrl: String?)
    
    func chatInputToolViewDidRequestStop(_ inputToolView: ChatInputToolView)
}

@MainActor
public class ChatInputToolView: UIView {
    
    // MARK: - Public Properties
    // Delegate
    public weak var delegate: ChatInputToolViewDelegate?
    
    // MARK: - UI Components
    // 子视图
    public let inputToolBar = ChatInputToolBar()
    private let customKeyboardPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    // 图片floatview
    private lazy var floatPhotoView = ChatInputFloatPhotoView()
    
    private let sendButton = UIButton(type: .custom)
    private let uploadButton = UIButton(type: .custom)
    
    // MARK: - Private Properties
    
    // 安全区域背景视图
    private let safeAreaBackgroundView = UIView()
    
    // InputToolBar 底部约束
    private var inputToolBarBottomConstraint: Constraint?
    
    // 当前键盘高度（系统键盘或自定义键盘）
    private var currentKeyboardHeight: CGFloat = 0.0
    
    // 相册管理类
    lazy var photoPicker = PhotoPickerManager()
    
    private var uploadImage:UIImage?
    private var uploadImageUrl:String?

    // 当前上传任务的 UUID
    private var currentUploadID: UUID?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupKeyboardObservers()
        setupInputBarConfigs()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Override Methods
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        safeAreaBackgroundView.frame = CGRectMake(0, inputToolBar.bottom, AppF.screenWidth,safeAreaInsets.bottom)
    }
    
    // 重写 hitTest 方法
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isHidden { return nil }
        // 允许需要响应的子视图处理事件
        for subview in [inputToolBar, customKeyboardPanel,floatPhotoView] {
            let convertedPoint = subview.convert(point, from: self)
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                return hitView
            }
        }
        return nil
    }
    
    // MARK: - Public Methods
    
    public func configureGenerateState(_ generating:Bool) {
        self.sendButton.isSelected = generating
    }
    
    public func resetContent() {
        configurePhotoImage(nil)
        inputToolBar.resetToolbar()
    }
    // MARK: - Private Methods
    
    // 设置 UI
    private func setupUI() {
        self.isUserInteractionEnabled = false  // 默认不响应事件
        
        // 添加子视图
        addSubview(safeAreaBackgroundView)
        addSubview(inputToolBar)
        safeAreaBackgroundView.backgroundColor = inputToolBar.backgroundColor
        safeAreaBackgroundView.autoresizingMask = [.flexibleTopMargin,.flexibleBottomMargin]
        safeAreaBackgroundView.frame = CGRectMake(0, inputToolBar.bottom, AppF.screenWidth,safeAreaInsets.bottom)
        addSubview(customKeyboardPanel)
        // 添加 InputToolBar 高度变化的监听
        inputToolBar.heightDidChange = { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
            let inputBarMinY = self.inputToolBar.frame.minY
            if inputBarMinY > 0 {
                self.delegate?.chatInputToolView(self, didChangeInputBarTopOffset: inputBarMinY, state: .inputBarHeightDidChange)
            }
        }
        // 设置安全区域背景视图颜色与 InputToolBar 一致
        safeAreaBackgroundView.backgroundColor = inputToolBar.backgroundColor
        
        // 布局 InputToolBar
        inputToolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            self.inputToolBarBottomConstraint = make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).constraint
        }
        
        // 布局自定义键盘面板
        customKeyboardPanel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(inputToolBar.snp.bottom)
            make.height.equalTo(0)
        }
        
        setupFloatPhotoView()
        
    }
    
    private func setupFloatPhotoView() {
        addSubview(floatPhotoView)
        floatPhotoView.isHidden = true
        // 点击回调
        floatPhotoView.onPhotoTap = {
            // 处理照片点击事件
            print("Photo tapped")
        }
        
        floatPhotoView.onCloseButtonTap = {[weak self] in
            // 关闭按钮点击事件
            print("Close button tapped")
            guard let self else { return }
            self.configurePhotoImage(nil)
        }
        floatPhotoView.snp.makeConstraints { make in
            make.size.equalTo(104)
            make.leading.equalTo(12)
            make.bottom.equalTo(inputToolBar.snp.top).offset(-12)
        }
    }
    
    
    
    // 键盘观察者
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notif:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notif:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func handleKeyboardWillShow(notif: Notification) {
        guard let userInfo = notif.userInfo else { return }
        
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let keyboardHeight = keyboardFrame.height - self.safeAreaInsets.bottom
        
        currentKeyboardHeight = keyboardHeight
        adjustInputToolBarPosition(with: keyboardHeight, notification: notif)
    }
    
    @objc private func handleKeyboardWillHide(notif: Notification) {
        currentKeyboardHeight = 0
        adjustInputToolBarPosition(with: currentKeyboardHeight, notification: notif)
    }
    
    private func adjustInputToolBarPosition(with keyboardHeight: CGFloat, notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        inputToolBarBottomConstraint?.update(offset: -keyboardHeight)
        
        // 确定状态
        let state: ChatInputToolViewState
        if notification.name == UIResponder.keyboardWillShowNotification {
            state = .systemKeyboardWillShow
        } else {
            state = .systemKeyboardWillHide
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: [animationCurve], animations: {
            self.layoutIfNeeded()
            let inputBarMinY = self.inputToolBar.frame.minY
            self.delegate?.chatInputToolView(self, didChangeInputBarTopOffset: inputBarMinY, state: state)
        }, completion: nil)
    }
    
}

// 在 ChatInputToolView 中添加显示和隐藏自定义键盘面板的方法
public extension ChatInputToolView {
    
    func showCustomKeyboardPanel() {
        self.endEditing(true)
        
        let customKeyboardHeight: CGFloat = 250
        
        customKeyboardPanel.snp.updateConstraints { make in
            make.height.equalTo(customKeyboardHeight)
        }
        
        currentKeyboardHeight = customKeyboardHeight
        inputToolBarBottomConstraint?.update(offset: -customKeyboardHeight)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            let inputBarMinY = self.inputToolBar.frame.minY
            self.delegate?.chatInputToolView(self, didChangeInputBarTopOffset: inputBarMinY, state: .customKeyboardWillShow)
        })
    }
    
    func hideCustomKeyboardPanel() {
        customKeyboardPanel.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        
        currentKeyboardHeight = 0
        inputToolBarBottomConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
            let inputBarMinY = self.inputToolBar.frame.minY
            self.delegate?.chatInputToolView(self, didChangeInputBarTopOffset: inputBarMinY, state: .customKeyboardWillHide)
        })
    }
}

extension ChatInputToolView {
    
    func setupInputBarConfigs() {
        
        // 配置右侧按钮
        sendButton.setImage(UIImage(named: "pop_send"), for: .normal)
        sendButton.setImage(UIImage(named: "pop_stop"), for: .selected)
        sendButton.setImage(UIImage(named: "pop_send_disable"), for: .disabled)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(28)
        }
        inputToolBar.addRightItemView(sendButton)
        
        uploadButton.setImage(UIImage(named: "pop_upload_img_ic"), for: .normal)
        uploadButton.setImage(UIImage(named: "pop_upload_img_ic_disable"), for: .disabled)
        uploadButton.addTarget(self, action: #selector(didTapUploadButton), for: .touchUpInside)
        uploadButton.snp.makeConstraints { make in
            make.size.equalTo(28)
        }
        inputToolBar.addLeftItemView(uploadButton)
        
        let line = UIView(color: UIColor(hex:"e5e5e5"))
        line.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 1, height: 28))
        }
        inputToolBar.addLeftItemView(line)
    }
    
    @objc func didTapSendButton() {
        if sendButton.isSelected {
            delegate?.chatInputToolViewDidRequestStop(self)
        } else if uploadImage != nil, uploadImageUrl == nil {
            AppHUD.showToast("You need to wait for the image upload to complete, or cancel the image upload.".localized)
        } else {
            let text = inputToolBar.growingTextView.state.text.trimmed()
            delegate?.chatInputToolView(self, didReturnSend: text, imageUrl: uploadImageUrl)
        }
    }
    
    @objc func didTapUploadButton() {
        guard let topViewController else { return }
        photoPicker.presentSelection(in: topViewController) { [weak self] image in
            guard let self else { return }
            self.configurePhotoImage(image)
        }
        
//        DocumentPickerManager.shared.openUploadFile(from: topViewController) { fileURL in
//            logDebug("upload FileURL: \(String(describing: fileURL))")
//        }
    }
    
    /// 配置上传图片
    /// - Parameter image: <#image description#>
    private func configurePhotoImage(_ image:UIImage?) {
        uploadImage = image
        if let image {
            floatPhotoView.isHidden = false
            floatPhotoView.setImage(image)
            uploadImage(image)
        } else {
            floatPhotoView.isHidden = true
            floatPhotoView.setImage(nil)
            cancelUpload()
        }
    }
}

// MARK: - Upload

extension ChatInputToolView {
    
    func uploadImage(_ image:UIImage) {
        
        floatPhotoView.updateProgress(0.1)
        Task {
            // 调用 ChatUploadCenter 上传图片并获取 uploadID
            let id = await ChatUploadCenter.shared.uploadImage(with: image)
            
            // 更新 UI 和保存 uploadID，需要在主线程上执行
            await MainActor.run {
                self.currentUploadID = id
            }
            
            // 监听上传进度
            await ChatUploadCenter.shared.uploadProgressStream
                .filter { [weak self] (uploadID, _) in
                    return uploadID == self?.currentUploadID
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (_, progress) in
                    guard let self else { return }
                    self.floatPhotoView.updateProgress(progress)
                }
                .store(in: &cancellables)
            
            // 监听上传完成
            await ChatUploadCenter.shared.uploadCompletionStream
                .filter { [weak self] (uploadID, _) in
                    return uploadID == self?.currentUploadID
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (_, result) in
                    guard let self else { return }
                    switch result {
                    case .success(let upload):
                        self.uploadImageUrl = upload.uploadUrl
                        self.floatPhotoView.uploadSucceed()
                    case .failure(let error):
                        AppHUD.showToast(error.localizedDescription)
                        self.floatPhotoView.uploadFailed()
                    }
                    self.currentUploadID = nil
                }
                .store(in: &cancellables)
        }
        
    }
    
    // MARK: - 取消上传
    private func cancelUpload() {
        Task {
            guard let id = currentUploadID else { return }
            await ChatUploadCenter.shared.cancelUpload(with: id)
            floatPhotoView.updateProgress(0.0)
            currentUploadID = nil
        }
    }
}
