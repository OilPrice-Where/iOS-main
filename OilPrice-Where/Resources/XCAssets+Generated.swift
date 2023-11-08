// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

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

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal enum Colors {
    internal static let darkMain = ColorAsset(name: "DarkMain")
    internal static let darkModeImageColor = ColorAsset(name: "DarkModeImageColor")
    internal static let darkRefresh = ColorAsset(name: "DarkRefresh")
    internal static let defaultColor = ColorAsset(name: "DefaultColor")
    internal static let mainColor = ColorAsset(name: "MainColor")
    internal static let mainColorAny = ColorAsset(name: "MainColorAny")
    internal static let tableViewBackground = ColorAsset(name: "TableViewBackground")
  }
  internal enum Images {
    internal static let _1pxDot = ImageAsset(name: "1px_dot")
    internal static let iconConvenience = ImageAsset(name: "IconConvenience")
    internal static let iconRepair = ImageAsset(name: "IconRepair")
    internal static let iconWash = ImageAsset(name: "IconWash")
    internal static let logoEnergyOne = ImageAsset(name: "LogoEnergyOne")
    internal static let logoExpresswayOil = ImageAsset(name: "LogoExpresswayOil")
    internal static let logoFrugalOil = ImageAsset(name: "LogoFrugalOil")
    internal static let logoGSCaltex = ImageAsset(name: "LogoGSCaltex")
    internal static let logoNHOil = ImageAsset(name: "LogoNHOil")
    internal static let logoOilBank = ImageAsset(name: "LogoOilBank")
    internal static let logoPersonalOil = ImageAsset(name: "LogoPersonalOil")
    internal static let logoSKEnergy = ImageAsset(name: "LogoSKEnergy")
    internal static let logoSKGas = ImageAsset(name: "LogoSKGas")
    internal static let logoSOil = ImageAsset(name: "LogoSOil")
    internal static let minMapMarker = ImageAsset(name: "MinMapMarker")
    internal static let nonMapMarker = ImageAsset(name: "NonMapMarker")
    internal static let selectMapMarker = ImageAsset(name: "SelectMapMarker")
    internal static let back = ImageAsset(name: "back")
    internal static let close = ImageAsset(name: "close")
    internal static let currentLocationButton = ImageAsset(name: "currentLocationButton")
    internal static let dieselImage = ImageAsset(name: "dieselImage")
    internal static let dropTheClothes = ImageAsset(name: "drop-the-clothes")
    internal static let favoriteIcon = ImageAsset(name: "favorite-icon")
    internal static let favoriteOffIcon = ImageAsset(name: "favoriteOffIcon")
    internal static let favoriteOnIcon = ImageAsset(name: "favoriteOnIcon")
    internal static let favoriteTabIcon = ImageAsset(name: "favoriteTabIcon")
    internal static let favoriteTabIconSel = ImageAsset(name: "favoriteTabIconSel")
    internal static let filter = ImageAsset(name: "filter")
    internal static let findMapIcon = ImageAsset(name: "findMapIcon")
    internal static let gasMachineImage = ImageAsset(name: "gasMachineImage")
    internal static let gasolinImage = ImageAsset(name: "gasolinImage")
    internal static let geoIcon = ImageAsset(name: "geoIcon")
    internal static let github = ImageAsset(name: "github")
    internal static let godLife = ImageAsset(name: "god-life")
    internal static let leftIcon = ImageAsset(name: "leftIcon")
    internal static let listIcon = ImageAsset(name: "list-icon")
    internal static let listButton = ImageAsset(name: "listButton")
    internal static let lpgImage = ImageAsset(name: "lpgImage")
    internal static let mapButton = ImageAsset(name: "mapButton")
    internal static let menuIcon = ImageAsset(name: "menuIcon")
    internal static let navigationIcon = ImageAsset(name: "navigationIcon")
    internal static let noneListImage = ImageAsset(name: "noneListImage")
    internal static let nonePageImage = ImageAsset(name: "nonePageImage")
    internal static let oilTabIcon = ImageAsset(name: "oilTabIcon")
    internal static let oilTabIconSel = ImageAsset(name: "oilTabIconSel")
    internal static let premiumImage = ImageAsset(name: "premiumImage")
    internal static let priceDownIcon = ImageAsset(name: "priceDownIcon")
    internal static let priceUpIcon = ImageAsset(name: "priceUpIcon")
    internal static let rightIcon = ImageAsset(name: "rightIcon")
    internal static let search = ImageAsset(name: "search")
    internal static let settingTabIcon = ImageAsset(name: "settingTabIcon")
    internal static let settingTabIconSel = ImageAsset(name: "settingTabIconSel")
    internal static let splash = ImageAsset(name: "splash")
    internal static let splashLogo = ImageAsset(name: "splashLogo")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
