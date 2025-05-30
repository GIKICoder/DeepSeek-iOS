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
        navigationBar.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)

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
        configurations = storageManager.getAllConfigurations()
        usageStats = storageManager.getUsageStatistics()
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
        iconImageView.image = UIImage(systemName: provider.iconName)
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        // Labels
        let titleLabel = UILabel()
        titleLabel.text = provider.displayName
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = config.selectedModel
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        // Status
        let statusDot = UIView()
        statusDot.backgroundColor = config.isActive ? .systemGreen : .systemOrange
        statusDot.layer.cornerRadius = 4
        
        let statusLabel = UILabel()
        statusLabel.text = config.isActive ? "已启用" : "已禁用"
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = config.isActive ? .systemGreen : .systemOrange
        
        // Settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = .gray
        
        // Toggle button
        let toggleButton = UIButton(type: .system)
        toggleButton.setTitle(config.isActive ? "禁用" : "启用", for: .normal)
        toggleButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        toggleButton.backgroundColor = config.isActive ? .systemRed : .systemGreen
        toggleButton.setTitleColor(.white, for: .normal)
        toggleButton.layer.cornerRadius = 8
        
        // Add subviews
        cardView.addSubview(iconContainer)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(statusDot)
        cardView.addSubview(statusLabel)
        cardView.addSubview(settingsButton)
        cardView.addSubview(toggleButton)
        
        // Actions
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped(_:)), for: .touchUpInside)
        settingsButton.tag = provider.id.hashValue
        
        toggleButton.addTarget(self, action: #selector(toggleButtonTapped(_:)), for: .touchUpInside)
        toggleButton.tag = provider.id.hashValue
        
        // Constraints
        iconContainer.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer.snp.trailing).offset(12)
            make.top.equalTo(iconContainer).offset(4)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        statusDot.snp.makeConstraints { make in
            make.trailing.equalTo(statusLabel.snp.leading).offset(-6)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(8)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(titleLabel)
        }
        
        toggleButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(60)
            make.height.equalTo(32)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalTo(toggleButton.snp.leading).offset(-12)
            make.centerY.equalTo(toggleButton)
            make.width.height.equalTo(24)
        }
        
        cardView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        return cardView
    }
    
    private func createAvailableModelCard(provider: ModelProvider) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
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
            self?.storageManager.saveConfiguration(configuration)
            self?.refreshData()
        }
        
        let navController = UINavigationController(rootViewController: apiKeyVC)
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
        } else {
            // Fallback on earlier versions
        }
        
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
                self?.storageManager.saveConfiguration(updatedConfig)
                self?.refreshData()
            }
            
            let navController = UINavigationController(rootViewController: apiKeyVC)
            navController.modalPresentationStyle = .pageSheet
            
            if #available(iOS 15.0, *) {
                if let sheet = navController.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                }
            } else {
                // Fallback on earlier versions
            }
            
            present(navController, animated: true)
        }
    }
    
    @objc private func toggleButtonTapped(_ sender: UIButton) {
        let providerHashValue = sender.tag
        if let provider = ModelProvider.allProviders.first(where: { $0.id.hashValue == providerHashValue }),
           var config = configurations.first(where: { $0.providerId == provider.id }) {
            
            config.isActive.toggle()
            storageManager.saveConfiguration(config)
            refreshData()
        }
    }
}
