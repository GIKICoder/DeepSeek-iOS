//
//  SettingViewController.swift
//  AppDomain
//
//  Created by GIKI on 2025/3/6.
//

import UIKit
import AppComponents
import AppInfra
import AppFoundation
import AppServices

enum SettingType: String {
    case termsofService = "用户协议"
    case privacyPolicy = "隐私政策"
    case thirdpart = "第三方信息共享清单"
    case permission = "应用权限"
    case update = "检查更新"
    case language = "应用语言"
    case theme = "颜色主题"
    case feedback = "联系我们"
    case logOut = "退出登录"
    case deleteHistory = "删除所有历史对话"
    case deleteAccount = "删除账号"
}


class SettingViewController: AppViewController {
    
    private let nestedScrollView = DNestedScrollView(nestedContainers: [])
    
    private let aboutSettingView = SettingSectionView()
    private let appSettingView = SettingSectionView()
    private let feedbackSettingView = SettingSectionView()
    private let logoutSettingView = SettingSectionView()
    private let deleteSettingView = SettingSectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {

        view.backgroundColor = UIColor(hex: "#EEF5F3")
        view.addSubview(nestedScrollView)
        nestedScrollView.backgroundColor = UIColor(hex: "#EEF5F3")
        nestedScrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-62)
        }
        setupContainers()
    }
    
    private func setupContainers() {
        nestedScrollView.removeAllContainers()
        nestedScrollView.addContainer(createPadding(40))
        nestedScrollView.addContainer(aboutSettingView)
        nestedScrollView.addContainer(createPadding(24))
        nestedScrollView.addContainer(appSettingView)
        nestedScrollView.addContainer(createPadding(24))
        nestedScrollView.addContainer(feedbackSettingView)
        nestedScrollView.addContainer(createPadding(24))
        nestedScrollView.addContainer(logoutSettingView)
        nestedScrollView.addContainer(createPadding(24))
        nestedScrollView.addContainer(deleteSettingView)
        
        configAboutSettings()
        configAppSettings()
        configFeedbackSettings()
        configLogoutSettings()
        configDeleteSettings()
        
    }
    
    private func configAboutSettings() {
        let items = [
            SettingItem(type: SettingType.termsofService.rawValue,
                        title: SettingType.termsofService.rawValue,
                        subtitle: nil,
                        icon: UIImage(named: "profile_setting_arrow")),
            SettingItem(type: SettingType.privacyPolicy.rawValue,
                        title: SettingType.privacyPolicy.rawValue,
                        subtitle: nil,
                        icon: UIImage(named: "profile_setting_arrow")),
            SettingItem(type: SettingType.thirdpart.rawValue,
                        title: SettingType.thirdpart.rawValue,
                        subtitle: nil,
                        icon: UIImage(named: "profile_setting_arrow")),
            SettingItem(type: SettingType.permission.rawValue,
                        title: SettingType.permission.rawValue,
                        subtitle: nil,
                        icon: UIImage(named: "profile_setting_arrow")),
            SettingItem(type: SettingType.update.rawValue,
                        title: SettingType.update.rawValue,
                        subtitle: nil,
                        icon: UIImage(named: "profile_setting_arrow")),
        ]

        aboutSettingView.configure(with: items)

        aboutSettingView.itemTapped = { [weak self] type in
            guard let self else { return }
            guard let settingType = SettingType(rawValue: type) else { return }
            switch settingType {
            case .feedback:
                print("Language Settings tapped")
            default: break
            }
        }
    }
    
    private func configAppSettings() {
        let items = [
            SettingItem(type: SettingType.language.rawValue,
                        title: SettingType.language.rawValue,
                        subtitle: "中文",
                        icon: UIImage(named: "profile_setting_arrow")),
            SettingItem(type: SettingType.theme.rawValue,
                        title: SettingType.theme.rawValue,
                        subtitle: "跟随系统",
                        icon: UIImage(named: "profile_setting_arrow")),
        ]

        appSettingView.configure(with: items)

        appSettingView.itemTapped = { [weak self] type in
            guard let self else { return }
            guard let settingType = SettingType(rawValue: type) else { return }
            switch settingType {
            case .feedback:
                print("Language Settings tapped")
            default: break
            }
        }
    }
    
    private func configFeedbackSettings() {
        let items = [
            SettingItem(type: SettingType.feedback.rawValue,
                        title: SettingType.feedback.rawValue,
                        subtitle: nil,
                        icon: nil)
        ]

        feedbackSettingView.configure(with: items)

        feedbackSettingView.itemTapped = { [weak self] type in
            guard let self else { return }
            guard let settingType = SettingType(rawValue: type) else { return }
            switch settingType {
            case .logOut:
                self.logout()
            default: break
            }
        }
    }
    
    
    private func configLogoutSettings() {
        let items = [
            SettingItem(type: SettingType.logOut.rawValue,
                        title: SettingType.logOut.rawValue,
                        subtitle: nil,
                        icon: nil)
        ]

        logoutSettingView.configure(with: items)

        logoutSettingView.itemTapped = { [weak self] type in
            guard let self else { return }
            guard let settingType = SettingType(rawValue: type) else { return }
            switch settingType {
            case .logOut:
                self.logout()
            default: break
            }
        }
    }
    
    private func configDeleteSettings() {
        let items = [
            SettingItem(type: SettingType.deleteHistory.rawValue,
                        title: SettingType.deleteHistory.rawValue,
                        titleColor: UIColor(hex: "#FF401A"),
                        subtitle: nil,
                        icon: nil),
            SettingItem(type: SettingType.deleteAccount.rawValue,
                        title: SettingType.deleteAccount.rawValue,
                        titleColor: UIColor(hex: "#FF401A"),
                        subtitle: nil,
                        icon: nil),
        ]

        deleteSettingView.configure(with: items)

        deleteSettingView.itemTapped = { [weak self] type in
            guard let self else { return }
            guard let settingType = SettingType(rawValue: type) else { return }
            switch settingType {
            case .logOut:
                print("did logout")
            default: break
            }
        }
    }
    
    private func createPadding(_ height:CGFloat) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: AppF.screenWidth, height: height)))
        return view
    }
    
    private func logout() {
        
        
        
        let alertVC = UIAlertController(title: NSLocalizedString("Confirm logout?", comment: ""),
                                       message: "",
                                       preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"),
                                  style: .cancel) { _ in
            // 取消操作的处理
        }
        alertVC.addAction(cancel)
        
        let logout = UIAlertAction(title: NSLocalizedString("Log out", comment: ""),
                                  style: .destructive) { [weak self] _ in
            self?.logoutReal()
        }
        alertVC.addAction(logout)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let view = self.view
            if let popoverController = alertVC.popoverPresentationController {
                popoverController.sourceView = view // Set the source view for the popover
                popoverController.sourceRect = CGRect(x: view!.bounds.midX,
                                                      y: view!.bounds.midY,
                                                    width: 0,
                                                    height: 0) // Set the source rect
                popoverController.permittedArrowDirections = .any // Set the arrow direction
            }
        }
        
        self.present(alertVC, animated: true)
    }
    
    private func logoutReal() {
        
    }
}
