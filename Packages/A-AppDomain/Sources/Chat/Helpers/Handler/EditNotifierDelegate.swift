//
//  File.swift
//  AppDomain
//
//  Created by GIKI on 2025/1/18.
//

import Foundation
import UIKit

public enum ActionDuration {
    case notAnimated
    case animated(duration: TimeInterval)
}

public protocol EditNotifierDelegate: AnyObject {
    func setIsEditing(_ isEditing: Bool, duration: ActionDuration)
    func didUpdateSelection(_ selectedItems: Set<ChatSection>)
}

public extension EditNotifierDelegate {
    func setIsEditing(_ isEditing: Bool, duration: ActionDuration) {}
    func didUpdateSelection(_ selectedItems: Set<ChatSection>) {}
}

