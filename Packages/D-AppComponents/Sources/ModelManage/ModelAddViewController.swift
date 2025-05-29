//
//  ModelAddViewController.swift
//  AppComponents
//
//  Created by GIKI on 2025/5/29.
//

import Foundation
import UIKit
import SnapKit

public class ModelAddViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    private let backButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let addButton = UIButton(type: .system)
    
    // Sections
    private let activeModelsStackView = UIStackView()
    private let localModelsStackView = UIStackView()
    private let availableModelsStackView = UIStackView()
    private let usageStatsView = UIView()
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupData()
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
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(activeModelsStackView)
        contentView.addSubview(localModelsStackView)
        contentView.addSubview(availableModelsStackView)
        contentView.addSubview(usageStatsView)
    }
    
    private func setupHeader() {
        headerView.backgroundColor = UIColor(red: 0.99, green: 0.99, blue: 1.0, alpha: 1.0)
        
        // Back button
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .darkGray
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Title
        titleLabel.text = "模型管理"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .black
        
        // Subtitle
        subtitleLabel.text = "配置AI模型和API密钥"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        // Add button
        addButton.backgroundColor = .white
        addButton.layer.cornerRadius = 16
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        addButton.layer.shadowOpacity = 0.1
        addButton.layer.shadowRadius = 2
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = UIColor.systemBlue
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(addButton)
    }
    
    private func setupStackViews() {
        [activeModelsStackView, localModelsStackView, availableModelsStackView].forEach { stackView in
            stackView.axis = .vertical
            stackView.spacing = 12
            stackView.alignment = .fill
        }
    }
    
    private func setupConstraints() {
        // Header constraints
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(80)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(backButton.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        // Scroll view constraints
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
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
        
        localModelsStackView.snp.makeConstraints { make in
            make.top.equalTo(activeModelsStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        availableModelsStackView.snp.makeConstraints { make in
            make.top.equalTo(localModelsStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        usageStatsView.snp.makeConstraints { make in
            make.top.equalTo(availableModelsStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func setupData() {
        setupActiveModels()
        setupLocalModels()
        setupAvailableModels()
        setupUsageStats()
    }
    
    private func setupActiveModels() {
        let sectionHeader = createSectionHeader(title: "已配置模型")
        activeModelsStackView.addArrangedSubview(sectionHeader)
        
        // GPT-4
        let gpt4Card = createActiveModelCard(
            iconName: "brain",
            iconColor: .systemGreen,
            title: "GPT-4",
            subtitle: "OpenAI",
            todayUsage: "127次",
            responseTime: "1.2s",
            isConnected: true
        )
        activeModelsStackView.addArrangedSubview(gpt4Card)
        
        // Claude
        let claudeCard = createActiveModelCard(
            iconName: "robot",
            iconColor: .systemBlue,
            title: "Claude",
            subtitle: "Anthropic",
            todayUsage: "43次",
            responseTime: "0.9s",
            isConnected: true
        )
        activeModelsStackView.addArrangedSubview(claudeCard)
        
        // DeepSeek
        let deepSeekCard = createActiveModelCard(
            iconName: "magnifyingglass",
            iconColor: .systemPurple,
            title: "DeepSeek",
            subtitle: "DeepSeek AI",
            todayUsage: "89次",
            responseTime: "0.7s",
            isConnected: true
        )
        activeModelsStackView.addArrangedSubview(deepSeekCard)
    }
    
    private func setupLocalModels() {
        let sectionHeader = createSectionHeader(title: "本地模型")
        localModelsStackView.addArrangedSubview(sectionHeader)
        
        let localCard = createActiveModelCard(
            iconName: "cpu",
            iconColor: .systemOrange,
            title: "本地助手",
            subtitle: "实时提示模型",
            todayUsage: "2.1GB",
            responseTime: "0.1s",
            isConnected: true,
            usageLabel: "内存使用"
        )
        localModelsStackView.addArrangedSubview(localCard)
    }
    
    private func setupAvailableModels() {
        let sectionHeader = createSectionHeader(title: "可添加模型")
        availableModelsStackView.addArrangedSubview(sectionHeader)
        
        // Gemini
        let geminiCard = createAvailableModelCard(
            iconName: "gem",
            title: "Gemini Pro",
            subtitle: "Google AI",
            buttonTitle: "添加"
        )
        availableModelsStackView.addArrangedSubview(geminiCard)
        
        // Custom Model
        let customCard = createAvailableModelCard(
            iconName: "plus",
            title: "自定义模型",
            subtitle: "添加其他API",
            buttonTitle: "配置"
        )
        availableModelsStackView.addArrangedSubview(customCard)
    }
    
    private func setupUsageStats() {
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
        
        let todayRequestsView = createStatView(value: "259", label: "今日总请求", color: .systemBlue)
        let avgResponseView = createStatView(value: "0.9s", label: "平均响应", color: .systemGreen)
        
        topStatsStack.addArrangedSubview(todayRequestsView)
        topStatsStack.addArrangedSubview(avgResponseView)
        
        // Monthly usage
        let monthlyLabel = UILabel()
        monthlyLabel.text = "本月使用量"
        monthlyLabel.font = UIFont.systemFont(ofSize: 14)
        monthlyLabel.textColor = .gray
        
        let usageLabel = UILabel()
        usageLabel.text = "7,432 / 10,000"
        usageLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        usageLabel.textColor = .black
        
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.74
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
    
    private func createActiveModelCard(
        iconName: String,
        iconColor: UIColor,
        title: String,
        subtitle: String,
        todayUsage: String,
        responseTime: String,
        isConnected: Bool,
        usageLabel: String = "今日使用"
    ) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowOpacity = 0.05
        cardView.layer.shadowRadius = 4
        
        // Icon
        let iconContainer = UIView()
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 12
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = iconColor
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        // Labels
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        // Status
        let statusDot = UIView()
        statusDot.backgroundColor = isConnected ? .systemGreen : .systemRed
        statusDot.layer.cornerRadius = 4
        
        let statusLabel = UILabel()
        statusLabel.text = isConnected ? "已连接" : "未连接"
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = isConnected ? .systemGreen : .systemRed
        
        // Stats
        let usageStatView = createStatView(value: todayUsage, label: usageLabel, color: .black, isSmall: true)
        let responseStatView = createStatView(value: responseTime, label: "响应时间", color: .black, isSmall: true)
        
        // Settings button
        let settingsButton = UIButton(type: .system)
        settingsButton.setImage(UIImage(systemName: "gearshape"), for: .normal)
        settingsButton.tintColor = .gray
        
        // Add subviews
        cardView.addSubview(iconContainer)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(statusDot)
        cardView.addSubview(statusLabel)
        cardView.addSubview(usageStatView)
        cardView.addSubview(responseStatView)
        cardView.addSubview(settingsButton)
        
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
        
        usageStatView.snp.makeConstraints { make in
            make.leading.equalTo(iconContainer)
            make.top.equalTo(iconContainer.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        responseStatView.snp.makeConstraints { make in
            make.leading.equalTo(usageStatView.snp.trailing).offset(32)
            make.centerY.equalTo(usageStatView)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(usageStatView)
            make.width.height.equalTo(24)
        }
        
        return cardView
    }
    
    private func createAvailableModelCard(
        iconName: String,
        title: String,
        subtitle: String,
        buttonTitle: String
    ) -> UIView {
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
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .gray
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        // Labels
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .darkGray
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        
        // Button
        let actionButton = UIButton(type: .system)
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        actionButton.layer.cornerRadius = 12
        
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
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(32)
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
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addButtonTapped() {
        // Handle add model action
        print("Add model tapped")
    }
}
