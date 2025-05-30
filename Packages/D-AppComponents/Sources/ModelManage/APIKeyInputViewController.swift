import Foundation
import UIKit

// MARK: - API Key Input View Controller
public class APIKeyInputViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    // MARK: - Properties
    private let provider: ModelProvider
    private let existingConfiguration: ModelConfiguration?
    public var onCompletion: ((ModelConfiguration) -> Void)?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let formStackView = UIStackView()
    private let apiKeySection = UIView()
    private let apiKeyTitleLabel = UILabel()
    private let apiKeyTextField = UITextField()
    private let apiKeyContainer = UIView()
    
    private let baseURLSection = UIView()
    private let baseURLTitleLabel = UILabel()
    private let baseURLTextField = UITextField()
    private let baseURLContainer = UIView()
    
    private let modelSection = UIView()
    private let modelTitleLabel = UILabel()
    private let modelPickerButton = UIButton()
    private let modelContainer = UIView()
    
    private let infoSection = UIView()
    private let infoLabel = UILabel()
    private let websiteButton = UIButton()
    
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    
    // Advanced Settings Sections
    private let temperatureSection = UIView()
    private let temperatureTitleLabel = UILabel()
    private let temperatureValueLabel = UILabel()
    private let temperatureSlider = UISlider()
    
    private let topPSection = UIView()
    private let topPTitleLabel = UILabel()
    private let topPValueLabel = UILabel()
    private let topPSlider = UISlider()
    
    private let contextLimitSection = UIView()
    private let contextLimitTitleLabel = UILabel()
    private let contextLimitValueLabel = UILabel()
    private let contextLimitSlider = UISlider()
    
    private var selectedModel: String
    
    // Settings Values
    private var temperature: Float = 0.7
    private var topP: Float = 0.9
    private var contextMessageLimit: Float = 100.0
    
    // MARK: - Lifecycle
    public init(provider: ModelProvider, existingConfiguration: ModelConfiguration? = nil) {
        self.provider = provider
        self.existingConfiguration = existingConfiguration
        self.selectedModel = existingConfiguration?.selectedModel ?? provider.supportModels.first ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        loadExistingConfiguration()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apiKeyTextField.becomeFirstResponder()
    }
    
    // MARK: - Private Methods
    private func loadExistingConfiguration() {
        if let existingConfiguration = existingConfiguration {
            apiKeyTextField.text = existingConfiguration.apiKey
            baseURLTextField.text = existingConfiguration.baseURL
            selectedModel = existingConfiguration.selectedModel
            
            // Load slider values
            temperature = existingConfiguration.temperature
            topP = existingConfiguration.topP
            contextMessageLimit = existingConfiguration.contextMessageLimit
            
            // Update UI elements
            temperatureSlider.value = temperature
            topPSlider.value = topP
            contextLimitSlider.value = contextMessageLimit
            
            // Update value labels
            temperatureValueLabel.text = String(format: "%.1f", temperature)
            topPValueLabel.text = String(format: "%.1f", topP)
            updateContextLimitValueLabel()
            
            updateModelButton()
            updateSaveButtonState()
            
            // Update title for editing mode
            titleLabel.text = "编辑 \(provider.displayName)"
            saveButton.setTitle("保存更改", for: .normal)
        } else {
            // Set default baseURL for new configuration
            baseURLTextField.text = provider.baseURL
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        // Header
        setupHeader()
        
        // Form
        setupForm()
        
        // Buttons
        setupButtons()
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(formStackView)
        contentView.addSubview(saveButton)
        contentView.addSubview(cancelButton)
    }
    
    private func setupHeader() {
        headerView.backgroundColor = UIColor.systemBackground
        
        // Icon
        iconContainer.backgroundColor = colorFromString(provider.iconColor).withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 24
        
        iconImageView.image = UIImage(named: provider.iconName) ?? UIImage(systemName: provider.iconName)
        iconImageView.contentMode = .scaleAspectFit
        
        iconContainer.addSubview(iconImageView)
        
        // Labels
        titleLabel.text = "配置 \(provider.displayName)"
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        
        subtitleLabel.text = provider.description
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0
        
        headerView.addSubview(iconContainer)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
    }
    
    private func setupForm() {
        formStackView.axis = .vertical
        formStackView.spacing = 24
        formStackView.alignment = .fill
        
        // API Key Section
        setupAPIKeySection()
        
        // Base URL Section
        setupBaseURLSection()
        
        // Model Selection Section
        setupModelSection()
        
        // Advanced Settings Sections
        setupTemperatureSection()
        setupTopPSection()
        setupContextLimitSection()
        
        // Info Section
        setupInfoSection()
        
        formStackView.addArrangedSubview(apiKeySection)
        formStackView.addArrangedSubview(baseURLSection)
        formStackView.addArrangedSubview(modelSection)
        formStackView.addArrangedSubview(temperatureSection)
        formStackView.addArrangedSubview(topPSection)
        formStackView.addArrangedSubview(contextLimitSection)
        formStackView.addArrangedSubview(infoSection)
    }
    
    private func setupAPIKeySection() {
        apiKeyTitleLabel.text = "API Key *"
        apiKeyTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        apiKeyTitleLabel.textColor = .label
        
        apiKeyContainer.backgroundColor = .secondarySystemGroupedBackground
        apiKeyContainer.layer.cornerRadius = 12
        apiKeyContainer.layer.borderWidth = 1
        apiKeyContainer.layer.borderColor = UIColor.separator.cgColor
        
        apiKeyTextField.placeholder = "请输入您的 \(provider.displayName) API Key"
        apiKeyTextField.font = UIFont.systemFont(ofSize: 16)
        apiKeyTextField.textColor = .label
        apiKeyTextField.isSecureTextEntry = true
        apiKeyTextField.backgroundColor = .clear
        apiKeyTextField.borderStyle = .none
        apiKeyTextField.returnKeyType = .done
        apiKeyTextField.autocapitalizationType = .none
        apiKeyTextField.autocorrectionType = .no
        apiKeyTextField.delegate = self
        
        apiKeyContainer.addSubview(apiKeyTextField)
        
        apiKeySection.addSubview(apiKeyTitleLabel)
        apiKeySection.addSubview(apiKeyContainer)
    }
    
    private func setupBaseURLSection() {
        baseURLTitleLabel.text = "Base URL"
        baseURLTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        baseURLTitleLabel.textColor = .label
        
        baseURLContainer.backgroundColor = .secondarySystemGroupedBackground
        baseURLContainer.layer.cornerRadius = 12
        baseURLContainer.layer.borderWidth = 1
        baseURLContainer.layer.borderColor = UIColor.separator.cgColor
        
        baseURLTextField.placeholder = "API的基础URL（可选，使用默认值）"
        baseURLTextField.font = UIFont.systemFont(ofSize: 16)
        baseURLTextField.textColor = .label
        baseURLTextField.backgroundColor = .clear
        baseURLTextField.borderStyle = .none
        baseURLTextField.keyboardType = .URL
        baseURLTextField.autocapitalizationType = .none
        baseURLTextField.autocorrectionType = .no
        baseURLTextField.returnKeyType = .done
        baseURLTextField.delegate = self
        baseURLContainer.addSubview(baseURLTextField)
        
        baseURLSection.addSubview(baseURLTitleLabel)
        baseURLSection.addSubview(baseURLContainer)
    }
    
    private func setupModelSection() {
        modelTitleLabel.text = "选择模型"
        modelTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        modelTitleLabel.textColor = .label
        
        modelContainer.backgroundColor = .secondarySystemGroupedBackground
        modelContainer.layer.cornerRadius = 12
        modelContainer.layer.borderWidth = 1
        modelContainer.layer.borderColor = UIColor.separator.cgColor
        
        updateModelButton()
        
        modelContainer.addSubview(modelPickerButton)
        
        modelSection.addSubview(modelTitleLabel)
        modelSection.addSubview(modelContainer)
    }
    
    private func setupInfoSection() {
        infoLabel.text = "如何获取API Key："
        infoLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        infoLabel.textColor = .secondaryLabel
        
        websiteButton.setTitle("访问 \(provider.displayName) 官网", for: .normal)
        websiteButton.setTitleColor(.systemBlue, for: .normal)
        websiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        websiteButton.contentHorizontalAlignment = .left
        
        infoSection.addSubview(infoLabel)
        infoSection.addSubview(websiteButton)
    }
    
    private func setupTemperatureSection() {
        temperatureTitleLabel.text = "Temperature"
        temperatureTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        temperatureTitleLabel.textColor = .label
        
        temperatureValueLabel.text = String(format: "%.2f", temperature)
        temperatureValueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        temperatureValueLabel.textColor = .secondaryLabel
        temperatureValueLabel.backgroundColor = UIColor.systemGray5
        temperatureValueLabel.textAlignment = .center
        temperatureValueLabel.layer.cornerRadius = 6
        temperatureValueLabel.clipsToBounds = true
        
        temperatureSlider.minimumValue = 0.0
        temperatureSlider.maximumValue = 2.0
        temperatureSlider.value = temperature
        temperatureSlider.isContinuous = true
        temperatureSlider.tintColor = .systemOrange
        temperatureSlider.addTarget(self, action: #selector(temperatureSliderChanged), for: .valueChanged)
        
        temperatureSection.addSubview(temperatureTitleLabel)
        temperatureSection.addSubview(temperatureValueLabel)
        temperatureSection.addSubview(temperatureSlider)
    }
    
    private func setupTopPSection() {
        topPTitleLabel.text = "Top P"
        topPTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        topPTitleLabel.textColor = .label
        
        topPValueLabel.text = String(format: "%.2f", topP)
        topPValueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        topPValueLabel.textColor = .secondaryLabel
        topPValueLabel.backgroundColor = UIColor.systemGray5
        topPValueLabel.textAlignment = .center
        topPValueLabel.layer.cornerRadius = 6
        topPValueLabel.clipsToBounds = true
        
        topPSlider.minimumValue = 0.0
        topPSlider.maximumValue = 1.0
        topPSlider.value = topP
        topPSlider.isContinuous = true
        topPSlider.tintColor = .systemBlue
        topPSlider.addTarget(self, action: #selector(topPSliderChanged), for: .valueChanged)
        
        topPSection.addSubview(topPTitleLabel)
        topPSection.addSubview(topPValueLabel)
        topPSection.addSubview(topPSlider)
    }
    
    private func setupContextLimitSection() {
        contextLimitTitleLabel.text = "上下文的消息数量上限"
        contextLimitTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contextLimitTitleLabel.textColor = .label
        
        updateContextLimitValueLabel()
        contextLimitValueLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contextLimitValueLabel.textColor = .secondaryLabel
        contextLimitValueLabel.backgroundColor = UIColor.systemGray5
        contextLimitValueLabel.textAlignment = .center
        contextLimitValueLabel.layer.cornerRadius = 6
        contextLimitValueLabel.clipsToBounds = true
        
        contextLimitSlider.minimumValue = 0.0
        contextLimitSlider.maximumValue = 510.0
        contextLimitSlider.value = contextMessageLimit
        contextLimitSlider.isContinuous = true
        contextLimitSlider.tintColor = .systemGreen
        contextLimitSlider.addTarget(self, action: #selector(contextLimitSliderChanged), for: .valueChanged)
        
        contextLimitSection.addSubview(contextLimitTitleLabel)
        contextLimitSection.addSubview(contextLimitValueLabel)
        contextLimitSection.addSubview(contextLimitSlider)
    }
    
    private func setupButtons() {
        saveButton.setTitle("保存配置", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.layer.cornerRadius = 12
        
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
    }
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        formStackView.translatesAutoresizingMaskIntoConstraints = false
        apiKeyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        apiKeyContainer.translatesAutoresizingMaskIntoConstraints = false
        apiKeyTextField.translatesAutoresizingMaskIntoConstraints = false
        baseURLTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        baseURLContainer.translatesAutoresizingMaskIntoConstraints = false
        baseURLTextField.translatesAutoresizingMaskIntoConstraints = false
        modelTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        modelContainer.translatesAutoresizingMaskIntoConstraints = false
        modelPickerButton.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        websiteButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Advanced Settings Components
        temperatureTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureValueLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureSlider.translatesAutoresizingMaskIntoConstraints = false
        topPTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topPValueLabel.translatesAutoresizingMaskIntoConstraints = false
        topPSlider.translatesAutoresizingMaskIntoConstraints = false
        contextLimitTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contextLimitValueLabel.translatesAutoresizingMaskIntoConstraints = false
        contextLimitSlider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header View
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 140),
            
            // Icon Container
            iconContainer.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 24),
            iconContainer.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            // Icon Image View
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Title Label
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -24),
            titleLabel.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            
            // Subtitle Label
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            // Form Stack View
            formStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 32),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // API Key Section
            apiKeyTitleLabel.topAnchor.constraint(equalTo: apiKeySection.topAnchor),
            apiKeyTitleLabel.leadingAnchor.constraint(equalTo: apiKeySection.leadingAnchor),
            apiKeyTitleLabel.trailingAnchor.constraint(equalTo: apiKeySection.trailingAnchor),
            
            apiKeyContainer.topAnchor.constraint(equalTo: apiKeyTitleLabel.bottomAnchor, constant: 8),
            apiKeyContainer.leadingAnchor.constraint(equalTo: apiKeySection.leadingAnchor),
            apiKeyContainer.trailingAnchor.constraint(equalTo: apiKeySection.trailingAnchor),
            apiKeyContainer.bottomAnchor.constraint(equalTo: apiKeySection.bottomAnchor),
            apiKeyContainer.heightAnchor.constraint(equalToConstant: 48),
            
            apiKeyTextField.leadingAnchor.constraint(equalTo: apiKeyContainer.leadingAnchor, constant: 16),
            apiKeyTextField.trailingAnchor.constraint(equalTo: apiKeyContainer.trailingAnchor, constant: -16),
            apiKeyTextField.centerYAnchor.constraint(equalTo: apiKeyContainer.centerYAnchor),
            
            // Base URL Section
            baseURLTitleLabel.topAnchor.constraint(equalTo: baseURLSection.topAnchor),
            baseURLTitleLabel.leadingAnchor.constraint(equalTo: baseURLSection.leadingAnchor),
            baseURLTitleLabel.trailingAnchor.constraint(equalTo: baseURLSection.trailingAnchor),
            
            baseURLContainer.topAnchor.constraint(equalTo: baseURLTitleLabel.bottomAnchor, constant: 8),
            baseURLContainer.leadingAnchor.constraint(equalTo: baseURLSection.leadingAnchor),
            baseURLContainer.trailingAnchor.constraint(equalTo: baseURLSection.trailingAnchor),
            baseURLContainer.bottomAnchor.constraint(equalTo: baseURLSection.bottomAnchor),
            baseURLContainer.heightAnchor.constraint(equalToConstant: 48),
            
            baseURLTextField.leadingAnchor.constraint(equalTo: baseURLContainer.leadingAnchor, constant: 16),
            baseURLTextField.trailingAnchor.constraint(equalTo: baseURLContainer.trailingAnchor, constant: -16),
            baseURLTextField.centerYAnchor.constraint(equalTo: baseURLContainer.centerYAnchor),
            
            // Model Section
            modelTitleLabel.topAnchor.constraint(equalTo: modelSection.topAnchor),
            modelTitleLabel.leadingAnchor.constraint(equalTo: modelSection.leadingAnchor),
            modelTitleLabel.trailingAnchor.constraint(equalTo: modelSection.trailingAnchor),
            
            modelContainer.topAnchor.constraint(equalTo: modelTitleLabel.bottomAnchor, constant: 8),
            modelContainer.leadingAnchor.constraint(equalTo: modelSection.leadingAnchor),
            modelContainer.trailingAnchor.constraint(equalTo: modelSection.trailingAnchor),
            modelContainer.bottomAnchor.constraint(equalTo: modelSection.bottomAnchor),
            modelContainer.heightAnchor.constraint(equalToConstant: 48),
            
            modelPickerButton.leadingAnchor.constraint(equalTo: modelContainer.leadingAnchor, constant: 16),
            modelPickerButton.trailingAnchor.constraint(equalTo: modelContainer.trailingAnchor, constant: -16),
            modelPickerButton.centerYAnchor.constraint(equalTo: modelContainer.centerYAnchor),
            
            // Info Section
            infoLabel.topAnchor.constraint(equalTo: infoSection.topAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: infoSection.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: infoSection.trailingAnchor),
            
            websiteButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            websiteButton.leadingAnchor.constraint(equalTo: infoSection.leadingAnchor),
            websiteButton.trailingAnchor.constraint(equalTo: infoSection.trailingAnchor),
            websiteButton.bottomAnchor.constraint(equalTo: infoSection.bottomAnchor),
            
            // Temperature Section
            temperatureTitleLabel.topAnchor.constraint(equalTo: temperatureSection.topAnchor),
            temperatureTitleLabel.leadingAnchor.constraint(equalTo: temperatureSection.leadingAnchor),
            
            temperatureValueLabel.topAnchor.constraint(equalTo: temperatureSection.topAnchor),
            temperatureValueLabel.trailingAnchor.constraint(equalTo: temperatureSection.trailingAnchor),
            temperatureValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: temperatureTitleLabel.trailingAnchor, constant: 8),
            temperatureValueLabel.widthAnchor.constraint(equalToConstant: 60),
            temperatureValueLabel.heightAnchor.constraint(equalToConstant: 28),
            
            temperatureSlider.topAnchor.constraint(equalTo: temperatureTitleLabel.bottomAnchor, constant: 10),
            temperatureSlider.leadingAnchor.constraint(equalTo: temperatureSection.leadingAnchor),
            temperatureSlider.trailingAnchor.constraint(equalTo: temperatureSection.trailingAnchor),
            temperatureSlider.bottomAnchor.constraint(equalTo: temperatureSection.bottomAnchor),
            temperatureSlider.heightAnchor.constraint(equalToConstant: 30),
            
            // Top P Section
            topPTitleLabel.topAnchor.constraint(equalTo: topPSection.topAnchor),
            topPTitleLabel.leadingAnchor.constraint(equalTo: topPSection.leadingAnchor),
            
            topPValueLabel.topAnchor.constraint(equalTo: topPSection.topAnchor),
            topPValueLabel.trailingAnchor.constraint(equalTo: topPSection.trailingAnchor),
            topPValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: topPTitleLabel.trailingAnchor, constant: 8),
            topPValueLabel.widthAnchor.constraint(equalToConstant: 60),
            topPValueLabel.heightAnchor.constraint(equalToConstant: 28),
            
            topPSlider.topAnchor.constraint(equalTo: topPTitleLabel.bottomAnchor, constant: 10),
            topPSlider.leadingAnchor.constraint(equalTo: topPSection.leadingAnchor),
            topPSlider.trailingAnchor.constraint(equalTo: topPSection.trailingAnchor),
            topPSlider.bottomAnchor.constraint(equalTo: topPSection.bottomAnchor),
            topPSlider.heightAnchor.constraint(equalToConstant: 30),
            
            // Context Limit Section
            contextLimitTitleLabel.topAnchor.constraint(equalTo: contextLimitSection.topAnchor),
            contextLimitTitleLabel.leadingAnchor.constraint(equalTo: contextLimitSection.leadingAnchor),
            
            contextLimitValueLabel.topAnchor.constraint(equalTo: contextLimitSection.topAnchor),
            contextLimitValueLabel.trailingAnchor.constraint(equalTo: contextLimitSection.trailingAnchor),
            contextLimitValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contextLimitTitleLabel.trailingAnchor, constant: 8),
            contextLimitValueLabel.widthAnchor.constraint(equalToConstant: 80),
            contextLimitValueLabel.heightAnchor.constraint(equalToConstant: 28),
            
            contextLimitSlider.topAnchor.constraint(equalTo: contextLimitTitleLabel.bottomAnchor, constant: 10),
            contextLimitSlider.leadingAnchor.constraint(equalTo: contextLimitSection.leadingAnchor),
            contextLimitSlider.trailingAnchor.constraint(equalTo: contextLimitSection.trailingAnchor),
            contextLimitSlider.bottomAnchor.constraint(equalTo: contextLimitSection.bottomAnchor),
            contextLimitSlider.heightAnchor.constraint(equalToConstant: 30),
            
            // Save Button
            saveButton.topAnchor.constraint(equalTo: formStackView.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Cancel Button
            cancelButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        modelPickerButton.addTarget(self, action: #selector(modelPickerButtonTapped), for: .touchUpInside)
        websiteButton.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
        
        // Add text field delegate for validation
        apiKeyTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        baseURLTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Add scroll view delegate to dismiss keyboard on scroll
        scrollView.delegate = self
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let apiKey = apiKeyTextField.text, !apiKey.trimmingCharacters(in: .whitespaces).isEmpty else {
            showAlert(title: "错误", message: "请输入有效的API Key")
            return
        }
        
        let baseURL = baseURLTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty == false ? 
            baseURLTextField.text! : provider.baseURL
        
        let configuration: ModelConfiguration
        
        if let existingConfig = existingConfiguration {
            // Update existing configuration
            configuration = ModelConfiguration(
                id: existingConfig.id,
                providerId: existingConfig.providerId,
                apiKey: apiKey,
                baseURL: baseURL,
                selectedModel: selectedModel,
                isActive: existingConfig.isActive,
                createdAt: existingConfig.createdAt,
                lastUsed: Date(),
                temperature: temperature,
                topP: topP,
                contextMessageLimit: contextMessageLimit
            )
        } else {
            // Create new configuration
            configuration = ModelConfiguration(
                id: UUID().uuidString,
                providerId: provider.id,
                apiKey: apiKey,
                baseURL: baseURL,
                selectedModel: selectedModel,
                isActive: true,
                createdAt: Date(),
                lastUsed: Date(),
                temperature: temperature,
                topP: topP,
                contextMessageLimit: contextMessageLimit
            )
        }
        
        onCompletion?(configuration)
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func modelPickerButtonTapped() {
        let alert = UIAlertController(title: "选择模型", message: nil, preferredStyle: .actionSheet)
        
        for model in provider.supportModels {
            let action = UIAlertAction(title: model, style: .default) { [weak self] _ in
                self?.selectedModel = model
                self?.updateModelButton()
            }
            if model == selectedModel {
                action.setValue(true, forKey: "checked")
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alert.popoverPresentationController {
            popover.sourceView = modelPickerButton
            popover.sourceRect = modelPickerButton.bounds
        }
        
        present(alert, animated: true)
    }
    
    @objc private func websiteButtonTapped() {
        if !provider.website.isEmpty,
           let url = URL(string: provider.website) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    @objc private func temperatureSliderChanged(_ sender: UISlider) {
        temperature = sender.value
        temperatureValueLabel.text = String(format: "%.2f", temperature)
    }
    
    @objc private func topPSliderChanged(_ sender: UISlider) {
        topP = sender.value
        topPValueLabel.text = String(format: "%.2f", topP)
    }
    
    @objc private func contextLimitSliderChanged(_ sender: UISlider) {
        contextMessageLimit = sender.value
        updateContextLimitValueLabel()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    private func updateModelButton() {
        modelPickerButton.setTitle(selectedModel, for: .normal)
        modelPickerButton.setTitleColor(.label, for: .normal)
        modelPickerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        modelPickerButton.contentHorizontalAlignment = .left
        
        // Add chevron
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevronImageView.tintColor = .secondaryLabel
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        modelPickerButton.addSubview(chevronImageView)
        NSLayoutConstraint.activate([
            chevronImageView.trailingAnchor.constraint(equalTo: modelPickerButton.trailingAnchor),
            chevronImageView.centerYAnchor.constraint(equalTo: modelPickerButton.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 16),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func updateSaveButtonState() {
        let hasApiKey = !(apiKeyTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        saveButton.isEnabled = hasApiKey
        saveButton.alpha = hasApiKey ? 1.0 : 0.5
    }
    
    private func updateContextLimitValueLabel() {
        if contextMessageLimit > 500 {
            contextLimitValueLabel.text = "无限制"
        } else {
            contextLimitValueLabel.text = "\(Int(contextMessageLimit))"
        }
    }
    
    private func colorFromString(_ colorString: String) -> UIColor {
        switch colorString {
        case "systemGreen": return .systemGreen
        case "systemBlue": return .systemBlue
        case "systemPurple": return .systemPurple
        case "systemRed": return .systemRed
        case "systemOrange": return .systemOrange
        default: return .systemBlue
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}
