//
//  FontMacro.swift
//
//
//  Created by 大桥 on 2024/6/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RegularFontMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) -> ExprSyntax {
      guard let argument = node.argumentList.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }
      
    return "UIFont.systemFont(ofSize: \(argument), weight: .regular) ?? UIFont.systemFont(ofSize: \(argument))"
  }
}

public struct SemiBoldFontMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) -> ExprSyntax {
      guard let argument = node.argumentList.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }

    return "UIFont.systemFont(ofSize: \(argument), weight: .semibold) ?? UIFont.systemFont(ofSize: \(argument))"
  }
}

public struct BoldFontMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) -> ExprSyntax {
      guard let argument = node.argumentList.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }
      //          .semibold .regular .medium .light
    return "UIFont.systemFont(ofSize: \(argument), weight: .bold) ?? UIFont.systemFont(ofSize: \(argument))"
  }
}

public struct MediumFontMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) -> ExprSyntax {
      guard let argument = node.argumentList.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }
    return "UIFont.systemFont(ofSize: \(argument), weight: .medium) ?? UIFont.systemFont(ofSize: \(argument))"
  }
}

public struct LightFontMacro: ExpressionMacro {
  public static func expansion(
    of node: some FreestandingMacroExpansionSyntax,
    in context: some MacroExpansionContext
  ) -> ExprSyntax {
      guard let argument = node.argumentList.first?.expression else {
      fatalError("compiler bug: the macro does not have any arguments")
    }
    return "UIFont.systemFont(ofSize: \(argument), weight: .light) ?? UIFont.systemFont(ofSize: \(argument))"
  }
}
