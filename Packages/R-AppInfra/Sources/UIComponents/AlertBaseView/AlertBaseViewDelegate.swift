///
//  @filename   AlertBaseViewDelegate.swift
//  @package   AppComponents
//  
//  @author     jeffy
//  @date       2024/10/25 
//  @abstract   
//
//  Copyright (c) 2024 and Confidential to jeffy All rights reserved.
//

import UIKit


// 定义弹窗通知
public extension Notification.Name {
    static let AlertViewDidDismiss = Notification.Name("alert.view.did.dismiss")
    static let AlertViewWillDismiss = Notification.Name("alert.view.will.dismiss")
    static let AlertViewWillShow = Notification.Name("alert.view.will.show")
    static let AlertViewDidShow = Notification.Name("alert.view.did.show")
}


@objc public protocol AlertBaseViewDelegate: AnyObject {
    @objc optional func actionAlertViewWillShow() // 即将出现
    @objc optional func actionAlertViewDidShow() // 已经出现
    @objc optional func actionAlertViewWillDismiss() // 即将消失
    @objc optional func actionAlertViewDidDismiss() // 已经消失
    @objc optional func actionAlertViewDidSelectBackGroundView() // 点击了背景
    
    /// 自定义展示的动画
    /// showAnimationType 需要设置为 .custom
    @objc optional func actionAlertViewShowAnimationCustom(_ alert: AlertBaseView)
    
    /// 自定义消失的动画
    /// hideAnimationType 需要设置为 .custom
    @objc optional func actionAlertViewHideAnimationCustom(_ alert: AlertBaseView)
}
