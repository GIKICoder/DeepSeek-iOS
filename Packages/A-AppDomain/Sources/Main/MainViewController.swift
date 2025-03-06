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
    
    private let maskContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()
    
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
        
        var channel = ChatChannel.default
        channel.channelId = "2222213412134213"
        let entrance = ChatEntrance(channel: channel)
        chatvc = createChat(entrance: entrance)
        addChild(chatvc!)
        view.addSubview(chatvc!.view)
        chatvc!.view.frame = contentFrame
        chatvc!.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        view.addSubview(maskContainer)
        maskContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupNavigationBar() {
        addNavigationbar()
        navigationBar.setTitle("新对话")
        navigationBar.addLeft(UIImage(named: "home_left_nav_ic"),target: self,action: #selector(didTapSideMenu))
        navigationBar.addRight(UIImage(named: "home_new_chat_ic"),target: self,action: #selector(didTapNewChat))
    }
    
    private func setupSideMenu() {
        SideMenuManager.default.leftMenuNavigationController = leftSideMenu
        SideMenuManager.default.leftMenuNavigationController?.settings = sideMenuSetting
        SideMenuManager.default.addPanGestureToPresent(toView: view)
    }
}

// MARK: - Chat DataSource
extension MainViewController {
    
    private func createChat(entrance:ChatEntrance = ChatEntrance()) -> ChatViewController {
        return ChatViewController(entrance: entrance)
    }
}

// MARK: - Action Method
extension MainViewController {
    
    @objc private func didTapSideMenu() {
        present(leftSideMenu, animated: true, completion: nil)
    }
    
    @objc private func didTapNewChat() {
        
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
