//
//  MainModelSettingPopover.swift
//  AppDomain
//
//  Created by GIKI on 2025/6/4.
//

import UIKit
import AppComponents
import AppInfra
import AppFoundation
import SnapKit


// MARK: - Main Popover Class
class MainModelSettingPopover: UIView {
    
    // MARK: - Properties
    private var selectedModel: AIModel?
    private var temperature: Float = 0.7
    private var topP: Float = 0.9
    private var contextMessageLimit: Float = 10
    private var activeConfigs: [ModelConfiguration] = ModelStorageManager.shared.activeConfigs()
    
    // MARK: - UI Components
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 24
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8).translatedBy(x: 0, y: -100)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "聊天设置"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor.label
        label.textAlignment = .center
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var segmentedControl: ModernSegmentedControl = {
        let control = ModernSegmentedControl(items: ["模型", "更多"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return control
    }()
    
    private lazy var modelTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(ModelTableViewCell.self, forCellReuseIdentifier: "ModelCell")
        tableView.sectionHeaderTopPadding = 0
//        tableView.sectionHeadersPinToVisibleBounds = true  // 置顶sectionHeader
        return tableView
    }()
    
    private lazy var settingsView: ModernParameterSettingsView = {
        let view = ModernParameterSettingsView()
        view.isHidden = true
        view.configure(
            temperature: temperature,
            topP: topP,
            contextLimit: contextMessageLimit
        ) { [weak self] temp, topP, limit in
            self?.temperature = temp
            self?.topP = topP
            self?.contextMessageLimit = limit
        }
        return view
    }()
    
    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        if let current = ModelStorageManager.shared.currentConfig() {
            self.selectedModel = current.selectedModel
            self.temperature = current.temperature
            self.topP = current.topP
            self.contextMessageLimit = current.contextMessageLimit
        }
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        addSubview(backgroundView)
        addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(segmentedControl)
        containerView.addSubview(modelTableView)
        containerView.addSubview(settingsView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(88+30)
            make.width.equalTo(360)
            make.height.lessThanOrEqualTo(UIScreen.main.bounds.height * 0.75)
            make.height.greaterThanOrEqualTo(400)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.width.height.equalTo(28)
        }
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(44)
        }
        
        modelTableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
        
        settingsView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    // MARK: - Public Methods
    func show(in parentView: UIView? = nil, sourceRect: CGRect = .zero) {
        let targetView: UIView
        
        if let parentView = parentView {
            targetView = parentView
        } else {
            // 添加到window
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                targetView = window
            } else {
                return
            }
        }
        
        targetView.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 调整弹窗位置（如果需要）
        if !sourceRect.isEmpty {
            let centerY = sourceRect.midY - 50
            containerView.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(centerY - targetView.bounds.midY)
            }
        }
        
        // 显示动画
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0) {
            self.backgroundView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.98, initialSpringVelocity: 0) {
            self.backgroundView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85).translatedBy(x: 0, y: -50)
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped() {
        hide()
    }
    
    @objc private func closeButtonTapped() {
        hide()
    }
    
    @objc private func segmentChanged(_ sender: ModernSegmentedControl) {
        let isModelTab = sender.selectedSegmentIndex == 0
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: {
            self.modelTableView.alpha = isModelTab ? 1 : 0
            self.settingsView.alpha = isModelTab ? 0 : 1
        }) { _ in
            self.modelTableView.isHidden = !isModelTab
            self.settingsView.isHidden = isModelTab
        }
    }
}

// MARK: - TableView DataSource & Delegate
extension MainModelSettingPopover: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return activeConfigs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let config = activeConfigs[section]
        return config.supportModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ModelCell", for: indexPath) as! ModelTableViewCell
        let model = activeConfigs[indexPath.section].supportModels[indexPath.row]
        let config = activeConfigs[indexPath.section]
        
        let isSelected = selectedModel?.value == model.value
        cell.configure(with: model, config: config, isSelected: isSelected)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ModelSectionHeaderView()
        headerView.configure(with: activeConfigs[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55  // 从60减少到50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let config = activeConfigs[indexPath.section]
        let model = config.supportModels[indexPath.row]
        
        // 更新选中状态
        let previousSelectedModel = selectedModel
        selectedModel = model
        var currentConfig = config
        currentConfig.selectedModel = model
        ModelStorageManager.shared.setCurrent(currentConfig)
        
        // 刷新相关行
        if let previousModel = previousSelectedModel {
            for (sectionIndex, config) in activeConfigs.enumerated() {
                if let rowIndex = config.supportModels.firstIndex(where: { $0.value == previousModel.value }) {
                    tableView.reloadRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .none)
                    break
                }
            }
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
        
        // 选中动效
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.15, animations: {
            cell?.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                cell?.transform = .identity
            }
        }
    }
}

// MARK: - Modern Segmented Control
class ModernSegmentedControl: UIControl {
    
    private let items: [String]
    private var buttons: [UIButton] = []
    private var selectorView: UIView!
    
    var selectedSegmentIndex: Int = 0 {
        didSet {
            updateSelection(animated: true)
        }
    }
    
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        
        // 创建选择器背景
        selectorView = UIView()
        selectorView.backgroundColor = UIColor.white
        selectorView.layer.cornerRadius = 10
        selectorView.layer.shadowColor = UIColor.black.cgColor
        selectorView.layer.shadowOpacity = 0.15
        selectorView.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectorView.layer.shadowRadius = 4
        addSubview(selectorView)
        
        // 创建按钮
        for (index, item) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(item, for: .normal)
            button.setTitleColor(UIColor.gray, for: .normal)
            button.setTitleColor(UIColor.black, for: .selected)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            button.backgroundColor = UIColor.clear
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            addSubview(button)
            buttons.append(button)
        }
        
        updateSelection(animated: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = bounds.width / CGFloat(buttons.count)
        
        for (index, button) in buttons.enumerated() {
            button.frame = CGRect(
                x: CGFloat(index) * buttonWidth,
                y: 0,
                width: buttonWidth,
                height: bounds.height
            )
        }
        
        updateSelectorPosition()
    }
    
    private func updateSelectorPosition() {
        let selectorWidth = bounds.width / CGFloat(buttons.count) - 8
        let selectorX = 4 + CGFloat(selectedSegmentIndex) * (bounds.width / CGFloat(buttons.count))
        
        selectorView.frame = CGRect(
            x: selectorX,
            y: 4,
            width: selectorWidth,
            height: bounds.height - 8
        )
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        let newIndex = sender.tag
        if newIndex != selectedSegmentIndex {
            selectedSegmentIndex = newIndex
            sendActions(for: .valueChanged)
        }
    }
    
    private func updateSelection(animated: Bool) {
        let updateBlock = {
            self.updateSelectorPosition()
            for (index, button) in self.buttons.enumerated() {
                button.isSelected = index == self.selectedSegmentIndex
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, animations: updateBlock)
        } else {
            updateBlock()
        }
    }
}

// MARK: - Model Table View Cell
class ModelTableViewCell: UITableViewCell {
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 8  // 稍微减小
        imageView.backgroundColor = UIColor.systemBackground
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)  // 稍微减小字体
        label.textColor = UIColor.label
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11, weight: .regular)  // 减小字体
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)  // 减小图标
        imageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: config)
        imageView.tintColor = UIColor.systemGreen
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(iconImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(descriptionLabel)
        cardView.addSubview(checkmarkImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        cardView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 20, bottom: 2, right: 20))  // 减少上下边距
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)  // 减少图标尺寸
        }
        
        checkmarkImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)  // 减少图标尺寸
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.trailing.equalTo(checkmarkImageView.snp.leading).offset(-10)
            make.top.equalToSuperview().offset(10)  // 减少上边距
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)  // 减少下边距
        }
    }
    
    func configure(with model: AIModel, config: ModelConfiguration, isSelected: Bool) {
        nameLabel.text = model.name
        descriptionLabel.text = model.description
        
        // 设置图标，不设置tintColor
        if let image = UIImage(named: model.avatar) {
            iconImageView.image = image
        } else if let provier = config.provider {
            iconImageView.image = UIImage(named: provier.iconName ) ?? UIImage(systemName: "brain.head.profile")
        }
        
        updateSelectedState(isSelected)
    }
    
    private func updateSelectedState(_ isSelected: Bool) {
        checkmarkImageView.isHidden = !isSelected
        
        if isSelected {
            cardView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            cardView.layer.borderWidth = 2
            cardView.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            cardView.backgroundColor = UIColor.secondarySystemGroupedBackground
            cardView.layer.borderWidth = 1  // 添加淡色边框
            cardView.layer.borderColor = UIColor.systemGray5.cgColor  // 淡色边框
        }
    }
}

// MARK: - Model Section Header View
class ModelSectionHeaderView: UIView {
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 6
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = UIColor.label
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(backgroundView)
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-24)
        }
    }
    
    func configure(with config: ModelConfiguration) {
        guard let provider = config.provider else { return }
        titleLabel.text = provider.displayName
        
        if let image = UIImage(named: provider.iconName) {
            iconImageView.image = image
        } else {
            iconImageView.image = UIImage(systemName: "brain.head.profile")
            // 不设置tintColor，保持系统默认
        }
    }
}

// MARK: - Modern Parameter Settings View
class ModernParameterSettingsView: UIView {
    
    private var valueChangeHandler: ((Float, Float, Float) -> Void)?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(24)
            make.width.equalToSuperview().offset(-48)  // 减少宽度以适应屏幕
        }
    }
    
    func configure(temperature: Float, topP: Float, contextLimit: Float, valueChangeHandler: @escaping (Float, Float, Float) -> Void) {
        self.valueChangeHandler = valueChangeHandler
        
        // 清空之前的视图
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let temperatureSlider = ModernParameterSlider(
            title: "温度 (Temperature)",
            subtitle: "控制回答的随机性，值越高越有创造性",
            value: temperature,
            range: 0...2,
            icon: "thermometer"
        ) { [weak self] value in
            self?.valueChangeHandler?(value, topP, contextLimit)
        }
        
        let topPSlider = ModernParameterSlider(
            title: "Top P",
            subtitle: "控制回答的多样性，影响词汇选择的范围",
            value: topP,
            range: 0...1,
            icon: "arrow.up.circle"
        ) { [weak self] value in
            self?.valueChangeHandler?(temperature, value, contextLimit)
        }
        
        let contextLimitSlider = ModernParameterSlider(
            title: "上下文消息限制",
            subtitle: "控制保留的历史消息数量",
            value: contextLimit,
            range: 1...500,
            icon: "message.badge"
        ) { [weak self] value in
            self?.valueChangeHandler?(temperature, topP, value)
        }
        
        stackView.addArrangedSubview(temperatureSlider)
        stackView.addArrangedSubview(topPSlider)
        stackView.addArrangedSubview(contextLimitSlider)
    }
}

// MARK: - Modern Parameter Slider
class ModernParameterSlider: UIView {
    
    private let valueChangeHandler: (Float) -> Void
    private var currentValue: Float = 0
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.red
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.secondarySystemGroupedBackground
        view.layer.borderWidth = 1  // 添加淡色边框
        view.layer.borderColor = UIColor.systemGray5.cgColor  // 淡色边框
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        imageView.preferredSymbolConfiguration = config
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.label
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.systemBlue
        label.textAlignment = .right
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.thumbTintColor = UIColor.systemBlue
        slider.minimumTrackTintColor = UIColor.systemBlue
        slider.maximumTrackTintColor = UIColor.systemGray4
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    init(title: String, subtitle: String, value: Float, range: ClosedRange<Float>, icon: String, valueChangeHandler: @escaping (Float) -> Void) {
        self.valueChangeHandler = valueChangeHandler
        super.init(frame: .zero)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = UIImage(systemName: icon)
        slider.minimumValue = range.lowerBound
        slider.maximumValue = range.upperBound
        slider.value = value
        currentValue = value
        updateValueLabel(value)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        
        // 添加子视图到容器
        containerView.addSubview(headerView)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(slider)
        
        // 头部视图内容
        headerView.addSubview(iconImageView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(valueLabel)
        
        // 设置约束
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(80)  // 增加高度以容纳更长的subtitle
        }
        
        // 头部视图约束
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(12)
        }
        
        // 副标题约束 - 增加高度
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        // 滑块约束
        slider.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
//            make.top.equalTo(subtitleLabel.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(20)
        }
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        currentValue = sender.value
        updateValueLabel(currentValue)
        valueChangeHandler(currentValue)
    }
    
    private func updateValueLabel(_ value: Float) {
        if slider.maximumValue <= 2 {
            valueLabel.text = String(format: "%.2f", value)
        } else {
            valueLabel.text = String(format: "%.0f", value)
        }
    }
}
