// swiftlint:disable:this file_name
// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum DeepSeekAsset: Sendable {
  public enum App {
  public static let frame1095Normal = DeepSeekImages(name: "Frame 1095_Normal")
    public static let frame872Normal = DeepSeekImages(name: "Frame 872_Normal")
    public static let frame986Normal = DeepSeekImages(name: "Frame 986_Normal")
    public static let frame990Normal = DeepSeekImages(name: "Frame 990_Normal")
    public static let arrowLeftMediumNormal = DeepSeekImages(name: "arrow.left.medium_Normal")
    public static let cameraRegularNormal = DeepSeekImages(name: "camera.regular_Normal")
    public static let chatAddCloseIc = DeepSeekImages(name: "chat_add_close_ic")
    public static let chatAddMoreIc = DeepSeekImages(name: "chat_add_more_ic")
    public static let chatContinueNormal = DeepSeekImages(name: "chat_continue_Normal")
    public static let chatSearchIc = DeepSeekImages(name: "chat_search_ic")
    public static let chatSendIcon = DeepSeekImages(name: "chat_send_icon")
    public static let chatStopIcon = DeepSeekImages(name: "chat_stop_icon")
    public static let chatThinkingIc = DeepSeekImages(name: "chat_thinking_ic")
    public static let closeNormal = DeepSeekImages(name: "close_Normal")
    public static let fileIconNormal = DeepSeekImages(name: "file_icon_Normal")
    public static let fileIconDisableNormal = DeepSeekImages(name: "file_icon_disable_Normal")
    public static let googleNormal = DeepSeekImages(name: "google_Normal")
    public static let imageColorfulNormal = DeepSeekImages(name: "image.colorful_Normal")
    public static let imageUnknownColorfulRawNormal = DeepSeekImages(name: "image.unknown.colorful.raw_Normal")
    public static let linkIcon1Normal = DeepSeekImages(name: "link_icon (1)_Normal")
    public static let loginNormal = DeepSeekImages(name: "login_Normal")
    public static let paperclipFilledRegularNormal = DeepSeekImages(name: "paperclip.filled.regular_Normal")
    public static let pencilNormal = DeepSeekImages(name: "pencil_Normal")
    public static let photoRegularNormal = DeepSeekImages(name: "photo.regular_Normal")
    public static let thinkArrowNormal = DeepSeekImages(name: "think_arrow_Normal")
    public static let titleNormal = DeepSeekImages(name: "title_Normal")
    public static let 警告图标Normal = DeepSeekImages(name: "警告图标_Normal")
    public static let dpIcon = DeepSeekImages(name: "dp_icon")
    public static let homeLeftNavIc = DeepSeekImages(name: "home_left_nav_ic")
    public static let homeNewChatIc = DeepSeekImages(name: "home_new_chat_ic")
    public static let messageCopyIc = DeepSeekImages(name: "message_copy_ic")
    public static let messageDislikeIc = DeepSeekImages(name: "message_dislike_ic")
    public static let messageDislikeIcHl = DeepSeekImages(name: "message_dislike_ic_hl")
    public static let messageLikeIc = DeepSeekImages(name: "message_like_ic")
    public static let messageLikeIcHl = DeepSeekImages(name: "message_like_ic_hl")
    public static let messageRegenIc = DeepSeekImages(name: "message_regen_ic")
    public static let profileDefaultIcon = DeepSeekImages(name: "profile_default_icon")
    public static let profileSettingArrow = DeepSeekImages(name: "profile_setting_arrow")
  }
  public enum Assets {
  public static let accentColor = DeepSeekColors(name: "AccentColor")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class DeepSeekColors: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  public var color: Color {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIColor: SwiftUI.Color {
      return SwiftUI.Color(asset: self)
  }
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension DeepSeekColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: DeepSeekColors) {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Color {
  init(asset: DeepSeekColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct DeepSeekImages: Sendable {
  public let name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
    let bundle = Bundle.module
    #if os(iOS) || os(tvOS) || os(visionOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, visionOS 1.0, *)
public extension SwiftUI.Image {
  init(asset: DeepSeekImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: DeepSeekImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: DeepSeekImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:enable all
// swiftformat:enable all
