//
//  SettingSectionView.swift
//  AppDomain
//
//  Created by GIKI on 2025/3/6.
//

import UIKit
import SnapKit
import AppFoundation

// SettingItem.swift
struct SettingItem {
    let type: String
    let title: String
    var titleColor: UIColor = .black
    var subtitle: String?
    let icon: UIImage?
}

// SettingItemView.swift
class SettingItemView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = .systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    var item: SettingItem? {
        didSet {
            updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(titleLabel)
        addSubview(iconImageView)
        addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(18)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.trailing.equalTo(iconImageView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    private func updateUI() {
        guard let item = item else { return }
        titleLabel.text = item.title
        titleLabel.textColor = item.titleColor
        if let image = item.icon {
            iconImageView.image = image
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
        if let subtitle = item.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }
}

// SettingSectionView.swift
class SettingSectionView: UIView {
    private let container: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    var itemTapped: ((String) -> Void)?
    private var items: [SettingItem] = []
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with items: [SettingItem]) {
        self.items = items
        setupView()
    }
    
    private func setupView() {
        container.subviews.forEach { $0.removeFromSuperview() }
        
        var lastItemView: UIView? = nil
        var totalHeight = 0
        
        for (index, item) in items.enumerated() {
            let itemView = SettingItemView()
            itemView.item = item
            container.addSubview(itemView)
            
            itemView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(43)
                
                if let lastView = lastItemView {
                    make.top.equalTo(lastView.snp.bottom)
                } else {
                    make.top.equalToSuperview()
                }
            }
            
            if index < items.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor(hex: "#E6E9F0")
                itemView.addSubview(separator)
                separator.snp.makeConstraints { make in
                    make.leading.equalTo(itemView).offset(12)
                    make.trailing.equalTo(itemView).inset(12)
                    make.bottom.equalTo(itemView)
                    make.height.equalTo(0.5)
                }
            }
            
            itemView.tag = index
            itemView.isUserInteractionEnabled = true
            itemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
            
            lastItemView = itemView
            totalHeight += 43
        }
        
        self.frame = CGRectMake(0, 0, AppF.screenWidth, CGFloat(totalHeight))
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        let index = view.tag
        guard index < items.count else { return }
        let item = items[index]
        itemTapped?(item.type)
    }
}
