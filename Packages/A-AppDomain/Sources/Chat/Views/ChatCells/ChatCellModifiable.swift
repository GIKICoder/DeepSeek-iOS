//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/21.
//

import Foundation

public protocol ChatCellModifiable {
    
    func configureContext(_ context: ChatContext?)
    
    func configure(section: ChatSection, layout: ChatMessageLayout, index: Int)
}
