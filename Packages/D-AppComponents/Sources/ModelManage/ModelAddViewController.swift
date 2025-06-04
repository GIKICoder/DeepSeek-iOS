//
//  ModelAddViewController.swift
//  AppComponents
//
//  Created by GIKI on 2025/5/29.
//

import Foundation
import UIKit
import SnapKit
import AppInfra

public class ModelAddViewController: AppViewController {
    
    // MARK: - Properties
    private let storageManager = ModelStorageManager.shared
    private var configurations: [ModelConfiguration] = []
    private var usageStats: UsageStatistics = UsageStatistics(
        todayRequests: 0,
        monthlyRequests: 0,
        monthlyLimit: 10000,
        averageResponseTime: 0.0,
        lastUpdated: Date()
    )
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    
    // Sections
    private let activeModelsStackView = UIStackView()
    private let availableModelsStackView = UIStackView()
    private let usageStatsView = UIView()
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadData()
        setupData()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        
        // Configure scroll view
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        
        // Configure header
        setupHeader()
        
        // Configure stack views
        setupStackViews()
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(activeModelsStackView)
        contentView.addSubview(availableModelsStackView)
        contentView.addSubview(usageStatsView)
    }
    
    private func setupHeader() {
        
        addCloseNavigationBar(title: "模型管理")
        navigationBar.setIgnoreStatusBar(true)
        navigationBar.setBackgroundColor(UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0))

    }
    
    private func setupStackViews() {
        [activeModelsStackView, availableModelsStackView].forEach { stackView in
            stackView.axis = .vertical
            stackView.spacing = 12
            stackView.alignment = .fill
        }
    }
    
    private func setupConstraints() {
        
        // Scroll view constraints
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Content constraints
        activeModelsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        availableModelsStackView.snp.makeConstraints { make in
            make.top.equalTo(activeModelsStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        usageStatsView.snp.makeConstraints { make in
            make.top.equalTo(availableModelsStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    // MARK: - Data Management
    private func loadData() {
        configurations = storageManager.allConfigs()
        usageStats = storageManager.getUsageStats()
    }
    
    private func refreshData() {
        loadData()
        setupData()
    }
    
    private func setupData() {
        setupActiveModels()
        setupAvailableModels()
        setupUsageStats()
    }
    
    private func setupActiveModels() {
        // Clear existing views
        activeModelsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let sectionHeader = createSectionHeader(title: configurations.isEmpty ? "暂无已配置模型" : "已配置模型")
        activeModelsStackView.addArrangedSubview(sectionHeader)
        
        if configurations.isEmpty {
            let emptyView = createEmptyStateView(
                title: "还没有配置任何模型",
                subtitle: "点击下方的模型厂商开始配置",
                iconName: "plus.circle"
            )
            activeModelsStackView.addArrangedSubview(emptyView)
        } else {
            for config in configurations {
                if let provider = config.provider {
                    let card = createActiveModelCard(
                        config: config,
                        provider: provider
                    )
                    activeModelsStackView.addArrangedSubview(card)
                }
            }
        }
    }
    
    private func setupAvailableModels() {
        // Clear existing views
        availableModelsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let sectionHeader = createSectionHeader(title: "可添加模型")
        availableModelsStackView.addArrangedSubview(sectionHeader)
        
        let configuredProviderIds = Set(configurations.map { $0.providerId })
        let availableProviders = ModelProvider.allProviders.filter { !configuredProviderIds.contains($0.id) }
        
        for provider in availableProviders {
            let card = createAvailableModelCard(provider: provider)
            availableModelsStackView.addArrangedSubview(card)
        }
    }
    
    private func setupUsageStats() {
        // Clear existing views
        usageStatsView.subviews.forEach { $0.removeFromSuperview() }
        
        let sectionHeader = createSectionHeader(title: "使用统计")
        usageStatsView.addSubview(sectionHeader)
        
        let statsCard = UIView()
        statsCard.backgroundColor = .white
        statsCard.layer.cornerRadius = 16
        statsCard.layer.shadowColor = UIColor.black.cgColor
        statsCard.layer.shadowOffset = CGSize(width: 0, height: 1)
        statsCard.layer.shadowOpacity = 0.05
        statsCard.layer.shadowRadius = 4
        
        // Top stats
        let topStatsStack = UIStackView()
        topStatsStack.axis = .horizontal
        topStatsStack.distribution = .fillEqually
        
        let todayRequestsView = createStatView(
            value: "\(usageStats.todayRequests)", 
            label: "今日总请求", 
            color: .systemBlue
        )
        let avgResponseView = createStatView(
            value: String(format: "%.1fs", usageStats.averageResponseTime), 
            label: "平均响应", 
            color: .systemGreen
        )
        
        topStatsStack.addArrangedSubview(todayRequestsView)
        topStatsStack.addArrangedSubview(avgResponseView)
        
        // Monthly usage
        let monthlyLabel = UILabel()
        monthlyLabel.text = "本月使用量"
        monthlyLabel.font = UIFont.systemFont(ofSize: 14)
        monthlyLabel.textColor = .gray
        
        let usageLabel = UILabel()
        usageLabel.text = "\(usageStats.monthlyRequests) / \(usageStats.monthlyLimit)"
        usageLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        usageLabel.textColor = .black
        
        let progressView = UIProgressView(progressViewStyle: .default)
        let progress = Float(usageStats.monthlyRequests) / Float(usageStats.monthlyLimit)
        progressView.progress = min(progress, 1.0)
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = UIColor(white: 0.9, alpha: 1.0)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        
        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        statsCard.addSubview(topStatsStack)
        statsCard.addSubview(separator)
        statsCard.addSubview(monthlyLabel)
        statsCard.addSubview(usageLabel)
        statsCard.addSubview(progressView)
        
        usageStatsView.addSubview(statsCard)
        
        // Constraints
        sectionHeader.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        statsCard.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        topStatsStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }
        
        separator.snp.makeConstraints { make in
            make.top.equalTo(topStatsStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        monthlyLabel.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }
        
        usageLabel.snp.makeConstraints { make in
            make.centerY.equalTo(monthlyLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        progressView.snp.makeConstraints { make in
            make.top.equalTo(monthlyLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(8)
        }
    }
    
    // MARK: - Helper Methods
    private func createSectionHeader(title: String) -> UILabel {
        let label = UILabel()
        label.text = title.uppercased()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .gray
        return label
    }
    
    private func createEmptyStateViewv2(title: String, subtitle: String, iconName: String) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowRadius = 4
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .systemGray3
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .tertiaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(32)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        return containerView
    }
    
    private func createActiveModelCard(config: ModelConfiguration, provider: ModelProvider) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowRadius = 4
        
        // Icon
        let iconContainer = UIView()
        let iconColor = colorFromString(provider.iconColor)
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 12
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: provider.iconName) ?? UIImage(systemName: provider.iconName)
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        // Labels
        let titleLabel = UILabel()
        titleLabel.text = provider.displayName
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        
//        let subtitleLabel = UILabel()
//        subtitleLabel.text = config.selectedModel
//        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
//        subtitleLabel.textColor = .gray
//        
        // Status badge
        let statusContainer = UIView()
        statusContainer.backgroundColor = config.isActive ? .systemGreen.withAlphaComponent(0.1) : .systemOrange.withAlphaComponent(0.1)
        statusContainer.layer.cornerRadius = 10
        
        let statusDot = UIView()
        statusDot.backgroundColor = config.isActive ? .systemGreen : .systemOrange
        statusDot.layer.cornerRadius = 3
        
        let statusLabel = UILabel()
        statusLabel.text = config.isActive ? "已启用" : "已禁用"
        statusLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        statusLabel.textColor = config.isActive ? .systemGreen : .systemOrange
        
        statusContainer.addSubview(statusDot)
        statusContainer.addSubview(statusLabel)
        
        // Menu button (更button for more actions)
        let moreButton = UIButton(type: .system)
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.tintColor = .systemGray
        moreButton.backgroundColor = UIColor.systemGray6
        moreButton.layer.cornerRadius = 14
        moreButton.showsMenuAsPrimaryAction = true
        
        // Create context menu
        let toggleAction = UIAction(
            title: config.isActive ? "禁用" : "启用",
            image: UIImage(systemName: config.isActive ? "pause.circle" : "play.circle"),
            attributes: config.isActive ? [.destructive] : []
        ) { [weak self] _ in
            self?.toggleButtonTapped(moreButton)
        }
        
        let settingsAction = UIAction(
            title: "设置",
            image: UIImage(systemName: "gearshape")
        ) { [weak self] _ in
            self?.settingsButtonTapped(moreButton)
        }
        
        let deleteAction = UIAction(
            title: "删除",
            image: UIImage(systemName: "trash"),
            attributes: [.destructive]
        ) { [weak self] _ in
            self?.deleteButtonTapped(moreButton)
        }
        
        moreButton.menu = UIMenu(children: [toggleAction, settingsAction, deleteAction])
        moreButton.tag = provider.id.hashValue
        
        // Add subviews
        cardView.addSubview(iconContainer)
        cardView.addSubview(titleLabel)
//        cardView.addSubview(subtitleLabel)
        cardView.addSubview(statusContainer)
        cardView.addSubview(moreButton)
        
        // Constraints
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.top.equalTo(iconContainer).offset(4)
            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
        }
        
//        subtitleLabel.snp.makeConstraints { make in
//            make.leading.equalTo(titleLabel)
//            make.top.equalTo(titleLabel.snp.bottom).offset(4)
//            make.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-8)
//        }
        
        statusContainer.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(20)
        }
        
        statusDot.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(6)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusDot.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
        
        moreButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(28)
        }
        
        cardView.snp.makeConstraints { make in
            make.height.equalTo(88)
        }
        
        return cardView
    }
    
    private func createAvailableModelCard(provider: ModelProvider) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        // Icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        iconContainer.layer.cornerRadius = 12
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: provider.iconName) ?? UIImage(systemName: provider.iconName)
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        // Labels
        let titleLabel = UILabel()
        titleLabel.text = provider.displayName
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .darkGray
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = provider.description
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 2
        
        // Button
        let actionButton = UIButton(type: .system)
        actionButton.setTitle("添加", for: .normal)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        actionButton.layer.cornerRadius = 12
        
        // Add tap action
        actionButton.addTarget(self, action: #selector(addModelButtonTapped(_:)), for: .touchUpInside)
        actionButton.tag = provider.id.hashValue
        
        // Add subviews
        cardView.addSubview(iconContainer)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(actionButton)
        
        // Constraints
        iconContainer.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(20)
            make.trailing.equalTo(actionButton.snp.leading).offset(-12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(32)
        }
        
        cardView.snp.makeConstraints { make in
            make.height.equalTo(88)
        }
        
        return cardView
    }
    
    private func createStatView(value: String, label: String, color: UIColor, isSmall: Bool = false) -> UIView {
        let container = UIView()
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: isSmall ? 14 : 24, weight: .bold)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        
        let labelLabel = UILabel()
        labelLabel.text = label
        labelLabel.font = UIFont.systemFont(ofSize: isSmall ? 10 : 14)
        labelLabel.textColor = .gray
        labelLabel.textAlignment = .center
        
        container.addSubview(valueLabel)
        container.addSubview(labelLabel)
        
        valueLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        labelLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(2)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        return container
    }
    
    // MARK: - Helper Methods
    private func colorFromString(_ colorString: String) -> UIColor {
        switch colorString.lowercased() {
        case "blue", "#007AFF":
            return .systemBlue
        case "green", "#34C759":
            return .systemGreen
        case "orange", "#FF9500":
            return .systemOrange
        case "red", "#FF3B30":
            return .systemRed
        case "purple", "#AF52DE":
            return .systemPurple
        case "pink", "#FF2D92":
            return .systemPink
        case "indigo", "#5856D6":
            return .systemIndigo
        case "teal", "#30B0C7":
            return .systemTeal
        default:
            return .systemBlue
        }
    }
    
    private func createEmptyStateView(title: String, subtitle: String, iconName: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 1)
        container.layer.shadowOpacity = 0.05
        container.layer.shadowRadius = 4
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .lightGray
        iconImageView.contentMode = .scaleAspectFit
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .lightGray
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        
        container.addSubview(iconImageView)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
            make.width.height.equalTo(48)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        return container
    }
    
    private func presentAPIKeyInput(for provider: ModelProvider) {
        let apiKeyVC = APIKeyInputViewController(provider: provider)
        apiKeyVC.onCompletion = { [weak self] configuration in
            self?.storageManager.saveConfig(configuration)
            self?.refreshData()
        }
        
        let navController = UINavigationController(rootViewController: apiKeyVC)
        present(navController, animated: true)
    }

    // MARK: - Actions
    
    @objc private func addModelButtonTapped(_ sender: UIButton) {
        let providerHashValue = sender.tag
        if let provider = ModelProvider.allProviders.first(where: { $0.id.hashValue == providerHashValue }) {
            presentAPIKeyInput(for: provider)
        }
    }
    
    @objc private func settingsButtonTapped(_ sender: UIButton) {
        let providerHashValue = sender.tag
        if let provider = ModelProvider.allProviders.first(where: { $0.id.hashValue == providerHashValue }),
           let config = configurations.first(where: { $0.providerId == provider.id }) {
            
            // Present settings for existing configuration
            let apiKeyVC = APIKeyInputViewController(provider: provider, existingConfiguration: config)
            apiKeyVC.onCompletion = { [weak self] updatedConfig in
                self?.storageManager.saveConfig(updatedConfig)
                self?.refreshData()
            }
            
            let navController = UINavigationController(rootViewController: apiKeyVC)
            present(navController, animated: true)
        }
    }
    
    @objc private func toggleButtonTapped(_ sender: UIButton) {
        let providerHashValue = sender.tag
        if let provider = ModelProvider.allProviders.first(where: { $0.id.hashValue == providerHashValue }),
           var config = configurations.first(where: { $0.providerId == provider.id }) {
            
            config.isActive.toggle()
            storageManager.saveConfig(config)
            refreshData()
        }
    }
    
    @objc private func deleteButtonTapped(_ sender: UIButton) {
        let providerHashValue = sender.tag
        if let provider = ModelProvider.allProviders.first(where: { $0.id.hashValue == providerHashValue }),
           let config = configurations.first(where: { $0.providerId == provider.id }) {
            presentDeleteConfirmation(for: provider, config: config)
        }
    }
    
    // MARK: - Delete Confirmation
    
    private func presentDeleteConfirmation(for provider: ModelProvider, config: ModelConfiguration) {
        let alert = UIAlertController(
            title: "删除模型配置",
            message: "确定要删除 \(provider.displayName) 的配置吗？\n\n此操作无法撤销，所有相关的设置和历史记录都会被删除。",
            preferredStyle: .alert
        )
        
        // 配置警告样式
        alert.setValue(NSAttributedString(
            string: alert.title ?? "",
            attributes: [
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
        ), forKey: "attributedTitle")
        
        alert.setValue(NSAttributedString(
            string: alert.message ?? "",
            attributes: [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.secondaryLabel
            ]
        ), forKey: "attributedMessage")
        
        // 取消按钮
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            // 可以添加取消时的动画或反馈
            self.provideCancelFeedback()
        }
        
        // 删除按钮 - 使用破坏性样式
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.performDelete(for: provider, config: config)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        // iPad 适配
        if let popover = alert.popoverPresentationController {
            // 找到删除按钮的视图
            if let deleteButton = findDeleteButton(with: provider.id.hashValue) {
                popover.sourceView = deleteButton
                popover.sourceRect = deleteButton.bounds
            } else {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            }
            popover.permittedArrowDirections = [.up, .down]
        }
        
        present(alert, animated: true) {
            // 弹窗出现时的反馈
            self.provideAlertPresentationFeedback()
        }
    }
    
    private func performDelete(for provider: ModelProvider, config: ModelConfiguration) {
        // 提供触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // 执行删除操作
        storageManager.removeConfig(for: provider.id)
        
        // 刷新数据并提供成功反馈
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.refreshData()
            self.provideDeleteSuccessFeedback()
        }
    }
    
    private func findDeleteButton(with tag: Int) -> UIView? {
        return view.subviews.first { subview in
            return subview.tag == tag && subview is UIButton
        }
    }
    
    // MARK: - Haptic Feedback
    
    private func provideCancelFeedback() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    private func provideAlertPresentationFeedback() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func provideDeleteSuccessFeedback() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
}
