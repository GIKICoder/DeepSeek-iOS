//
//  File.swift
//  AppMacro
//
//  Created by GIKI on 2025/1/10.
//

import Foundation
import UIKit

@freestanding(expression)
public macro regular(_ size: CGFloat) -> UIFont = #externalMacro(module: "AppMacroMacros", type: "RegularFontMacro")

@freestanding(expression)
public macro bold(_ size: CGFloat) -> UIFont = #externalMacro(module: "AppMacroMacros", type: "BoldFontMacro")

@freestanding(expression)
public macro medium(_ size: CGFloat) -> UIFont = #externalMacro(module: "AppMacroMacros", type: "MediumFontMacro")

@freestanding(expression)
public macro light(_ size: CGFloat) -> UIFont = #externalMacro(module: "AppMacroMacros", type: "LightFontMacro")

@freestanding(expression)
public macro semiBold(_ size: CGFloat) -> UIFont = #externalMacro(module: "AppMacroMacros", type: "SemiBoldFontMacro")
