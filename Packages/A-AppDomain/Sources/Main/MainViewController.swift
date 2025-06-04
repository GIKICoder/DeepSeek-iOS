//
//  MainViewController.swift
//  AppDomain
//
//  Created by GIKI on 2025/3/5.
//

import UIKit
import AppComponents
import AppInfra
import SideMenu
import AppFoundation
import AppServices

public class MainViewController: AppViewController {

    lazy var leftSideMenu: SideMenuNavigationController = {
        let side = SideMenuNavigationController(rootViewController: historyVC)
        return side
    }()
    lazy var historyVC: HistoryViewController = {
        return HistoryViewController()
    }()
    
    lazy var sideMenuSetting: SideMenuSettings = {
        var settings = SideMenuSettings()
        settings.presentationStyle = .viewSlideOutMenuIn
        settings.menuWidth = AppF.screenWidth * 0.7
        return settings
    }()
    
    lazy var noteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "home_note_chat_ic"), for: .normal)
        button.setImage(UIImage(named: "home_note_cancel_ic"), for: .selected)
        button.addTarget(self, action: #selector(didTapNoteChat), for: .touchUpInside)
        return button
    }()
    
    private let maskContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()
    
    let modelSelectView = MainModelSelectView()
    
    private var chatvc: ChatViewController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

}

// MARK: - Setup UI
extension MainViewController {

    private func setupUI() {
        setupNavigationBar()
        setupSideMenu()
    
        let entrance = ChatEntrance(channel: nil)
        chatvc = createChat(entrance: entrance)
        addChild(chatvc!)
        view.addSubview(chatvc!.view)
        chatvc!.view.frame = contentFrame
        chatvc!.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        view.addSubview(maskContainer)
        maskContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        historyVC.didSelectModelCallback = {[weak self] selectedModel in
            guard let self else { return }
            self.updateNewChat(with:selectedModel)
        }
    }
    
    private func setupNavigationBar() {
        addNavigationbar()
        navigationBar.addLeft(UIImage(named: "home_left_nav_ic"),target: self,action: #selector(didTapSideMenu))
        navigationBar.addRight(UIImage(named: "home_new_chat_ic"),target: self,action: #selector(didTapNewChat))
        let noteItem = NavigationItem(view: noteButton,size: CGSize(width: 24, height: 24))
        navigationBar.addRightItem(noteItem)
        
        navigationBar.addSubview(modelSelectView)
        modelSelectView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(navigationBar.contentView.snp.centerY)
        }
        modelSelectView.addTarget(self, action: #selector(modelSelectTapped), for: .touchUpInside)
        
        if let active = ModelStorageManager.shared.getCurrentActiveConfiguration() {
            modelSelectView.configure(
                providerIcon: UIImage(named: active.provider?.iconName ?? "default_ic"),
                modelInfo: active.selectedModel,
                isSelectable: true
            )
        } else {
            modelSelectView.configure(
                providerIcon: nil,
                modelInfo: "Not Configured",
                isSelectable: true
            )
        }
    }
    
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = leftSideMenu
        SideMenuManager.default.leftMenuNavigationController?.settings = sideMenuSetting
        SideMenuManager.default.addPanGestureToPresent(toView: view)
    }
    
    private func bringSubviewToFront() {
        view.bringSubviewToFront(navigationBar)
        view.bringSubviewToFront(maskContainer)
    }
}

// MARK: - Chat DataSource
extension MainViewController {
    
    private func addNewChat() {
        let entrance = ChatEntrance(channel: nil)
        chatvc = createChat(entrance: entrance)
        addChild(chatvc!)
        view.addSubview(chatvc!.view)
        chatvc!.view.frame = contentFrame
        chatvc!.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        bringSubviewToFront()
    }
    
    private func replaceChat(with model:ChatSessionHistory) {
        
        removeCurrentChat()
        
        var channel = ChatChannel.default
        channel.id  = model.id
        let entrance = ChatEntrance(channel: channel)
        chatvc = createChat(entrance: entrance)
        addChild(chatvc!)
        view.addSubview(chatvc!.view)
        chatvc!.view.frame = contentFrame
        chatvc!.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        bringSubviewToFront()
    }

    private func removeCurrentChat() {
        
        guard let chatViewController = chatvc else { return }
        
        chatViewController.willMove(toParent: nil)
        chatViewController.view.removeFromSuperview()
        chatViewController.removeFromParent()
    
        chatvc = nil
    }
    
    private func createChat(entrance:ChatEntrance = ChatEntrance()) -> ChatViewController {
        return ChatViewController(entrance: entrance)
    }
    
    private func updateNewChat(with model:ChatSessionHistory) {
        leftSideMenu.dismiss(animated: true)
        replaceChat(with: model)
    }
}

// MARK: - Action Method
extension MainViewController {
    
    @objc private func didTapSideMenu() {
        present(leftSideMenu, animated: true, completion: nil)
    }
    
    @objc private func didTapNewChat() {
        if let chatvc = chatvc,chatvc.dataCenter.messages.isEmpty {
            AppHUD.showToast("已经在新对话中")
            return
        }
        addNewChat()
    }
    
    @objc private func didTapNoteChat() {
        chatvc?.toggleNoteChat()
        noteButton.isSelected = !noteButton.isSelected
        if noteButton.isSelected {
            chatvc?.showEditAction()
        } else {
            chatvc?.hiddenEditAction()
        }
    }
    
    @objc private func modelSelectTapped() {
        if ModelStorageManager.shared.getActiveConfigurations().isEmpty {
            let vc = ModelAddViewController()
            present(vc, animated: true)
            return
        }
        // 创建和显示弹窗
        let popover = MainModelSettingPopover()
        popover.show()
        /// , sourceRect: self.modelSelectView.frame
    }
}

extension MainViewController: SideMenuNavigationControllerDelegate {
    
    public func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
    
    public func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
        maskContainer.isHidden = false
    }
    
    public func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    public func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
        maskContainer.isHidden = true
    }
}
