//
//  ShareBottomToolView.swift
//  AppDomain
//
//  Created by GIKI on 2025/2/4.
//

import UIKit
import AppFoundation
import AppInfra

class ShareBottomToolView: UIView {
    
    private var checkBox: UIButton!
    private var titleLabel: UILabel!
    private var countLabel: UILabel!
    private var shareBtn: UIButton!
    
    var select_all: Bool = false {
        didSet {
            checkBox.isSelected = select_all
        }
    }
    
    var select_count: Int = 0 {
        didSet {
            countLabel.text = String(format: NSLocalizedString("%ld messages selected", comment: ""), select_count)
            if select_count == 0 {
                checkBox.isSelected = false
            }
        }
    }
    
    var shareCreateAction: (() -> Void)?
    var selectAll: ((Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        // CheckBox
        checkBox = {
            let button = UIButton(type: .custom)
            button.addTarget(self, action: #selector(checkBoxAction(_:)), for: .touchUpInside)
            button.setImage(UIImage(named: "pop_chat_select_all"), for: .normal)
            button.setImage(UIImage(named: "pop_chat_select"), for: .selected)
            addSubview(button)
            return button
        }()
        
        // Title Label
        titleLabel = {
            let label = UILabel()
            label.textColor = .black.withAlphaComponent(0.88)
            label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
            label.textAlignment = .left
            label.text = NSLocalizedString("Select all", comment: "")
            addSubview(label)
            return label
        }()
        
        // Count Label
        countLabel = {
            let label = UILabel()
            label.textColor = .black.withAlphaComponent(0.6)
            label.font = UIFont.systemFont(ofSize: 13)
            label.textAlignment = .left
            label.text = String(format: NSLocalizedString("%ld messages selected", comment: ""), 0)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            addSubview(label)
            return label
        }()
        
        // Share Button
        shareBtn = {
            let button = UIButton(type: .custom)
            button.backgroundColor = UIColor(hex:"3C38FF")
            button.layer.cornerRadius = 10
            button.layer.masksToBounds = true
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
            button.setTitleColor(.white, for: .normal)
            button.setTitle(NSLocalizedString("Copy share link", comment: ""), for: .normal)
            button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            addSubview(button)
            return button
        }()
        
        // Additional Button
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(checkBoxAction(_:)), for: .touchUpInside)
        addSubview(button)
        
        // Setup Constraints
        button.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.bottom.equalTo(shareBtn.snp.bottom)
            make.trailing.equalTo(shareBtn.snp.leading).offset(-10)
        }
        
        checkBox.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.equalTo(16)
            make.top.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkBox.snp.trailing).offset(12)
            make.top.equalTo(checkBox.snp.top).offset(-3)
        }
        
        countLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom)
            make.trailing.equalTo(shareBtn.snp.leading).offset(-8)
        }
        
        shareBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 138, height: 44))
            make.top.equalTo(16)
            make.trailing.equalTo(self.snp.trailing).offset(-16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonClick(_ sender: UIButton) {
        shareCreateAction?()
    }
    
    @objc private func checkBoxAction(_ sender: UIButton) {
        checkBox.isSelected = !checkBox.isSelected
        selectAll?(!checkBox.isSelected)
    }
}
