@_exported import SwiftCompilerPlugin
@_exported import SwiftDiagnostics
@_exported import SwiftSyntax
@_exported import SwiftSyntaxBuilder
@_exported import SwiftSyntaxMacros

@main
struct MacroKitPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        RegularFontMacro.self,
        SemiBoldFontMacro.self,
        BoldFontMacro.self,
        MediumFontMacro.self,
        LightFontMacro.self
    ]
}
