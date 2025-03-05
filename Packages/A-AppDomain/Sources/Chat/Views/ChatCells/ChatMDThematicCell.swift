//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/23.
//

import Foundation
import UIKit
import MPITextKit
import GMarkdown
import IQListKit

@MainActor
public class ChatMDThematicCell: ChatContentCell {
    
    private let line = UIView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        messageView.addSubview(line)
        line.backgroundColor = .black.withAlphaComponent(0.6)
        line.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    @available(*, unavailable)
    required public init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    public override func configure(section: ChatSection, layout: ChatMessageLayout, index: Int) {
        super.configure(section: section, layout: layout, index: index)
    }
}
