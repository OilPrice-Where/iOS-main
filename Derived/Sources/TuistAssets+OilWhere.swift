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

// MARK: - Asset Catalogs

public enum OilWhereAsset: Sendable {
  public enum Colors {
  public static let darkMain = OilWhereColors(name: "DarkMain")
    public static let darkModeImageColor = OilWhereColors(name: "DarkModeImageColor")
    public static let darkRefresh = OilWhereColors(name: "DarkRefresh")
    public static let defaultColor = OilWhereColors(name: "DefaultColor")
    public static let mainColor = OilWhereColors(name: "MainColor")
    public static let mainColorAny = OilWhereColors(name: "MainColorAny")
    public static let tableViewBackground = OilWhereColors(name: "TableViewBackground")
  }
  public enum Images {
  public static let _1pxDot = OilWhereImages(name: "1px_dot")
    public static let iconConvenience = OilWhereImages(name: "IconConvenience")
    public static let iconRepair = OilWhereImages(name: "IconRepair")
    public static let iconWash = OilWhereImages(name: "IconWash")
    public static let logoEnergyOne = OilWhereImages(name: "LogoEnergyOne")
    public static let logoExpresswayOil = OilWhereImages(name: "LogoExpresswayOil")
    public static let logoFrugalOil = OilWhereImages(name: "LogoFrugalOil")
    public static let logoGSCaltex = OilWhereImages(name: "LogoGSCaltex")
    public static let logoNHOil = OilWhereImages(name: "LogoNHOil")
    public static let logoOilBank = OilWhereImages(name: "LogoOilBank")
    public static let logoPersonalOil = OilWhereImages(name: "LogoPersonalOil")
    public static let logoSKEnergy = OilWhereImages(name: "LogoSKEnergy")
    public static let logoSKGas = OilWhereImages(name: "LogoSKGas")
    public static let logoSOil = OilWhereImages(name: "LogoSOil")
    public static let minMapMarker = OilWhereImages(name: "MinMapMarker")
    public static let nonMapMarker = OilWhereImages(name: "NonMapMarker")
    public static let selectMapMarker = OilWhereImages(name: "SelectMapMarker")
    public static let back = OilWhereImages(name: "back")
    public static let close = OilWhereImages(name: "close")
    public static let currentLocationButton = OilWhereImages(name: "currentLocationButton")
    public static let dieselImage = OilWhereImages(name: "dieselImage")
    public static let dropTheClothes = OilWhereImages(name: "drop-the-clothes")
    public static let favoriteIcon = OilWhereImages(name: "favorite-icon")
    public static let favoriteOffIcon = OilWhereImages(name: "favoriteOffIcon")
    public static let favoriteOnIcon = OilWhereImages(name: "favoriteOnIcon")
    public static let favoriteTabIcon = OilWhereImages(name: "favoriteTabIcon")
    public static let favoriteTabIconSel = OilWhereImages(name: "favoriteTabIconSel")
    public static let filter = OilWhereImages(name: "filter")
    public static let findMapIcon = OilWhereImages(name: "findMapIcon")
    public static let gasMachineImage = OilWhereImages(name: "gasMachineImage")
    public static let gasolinImage = OilWhereImages(name: "gasolinImage")
    public static let geoIcon = OilWhereImages(name: "geoIcon")
    public static let github = OilWhereImages(name: "github")
    public static let godLife = OilWhereImages(name: "god-life")
    public static let leftIcon = OilWhereImages(name: "leftIcon")
    public static let listIcon = OilWhereImages(name: "list-icon")
    public static let listButton = OilWhereImages(name: "listButton")
    public static let lpgImage = OilWhereImages(name: "lpgImage")
    public static let mapButton = OilWhereImages(name: "mapButton")
    public static let menuIcon = OilWhereImages(name: "menuIcon")
    public static let navigationIcon = OilWhereImages(name: "navigationIcon")
    public static let noneListImage = OilWhereImages(name: "noneListImage")
    public static let nonePageImage = OilWhereImages(name: "nonePageImage")
    public static let oilTabIcon = OilWhereImages(name: "oilTabIcon")
    public static let oilTabIconSel = OilWhereImages(name: "oilTabIconSel")
    public static let premiumImage = OilWhereImages(name: "premiumImage")
    public static let priceDownIcon = OilWhereImages(name: "priceDownIcon")
    public static let priceUpIcon = OilWhereImages(name: "priceUpIcon")
    public static let rightIcon = OilWhereImages(name: "rightIcon")
    public static let search = OilWhereImages(name: "search")
    public static let settingTabIcon = OilWhereImages(name: "settingTabIcon")
    public static let settingTabIconSel = OilWhereImages(name: "settingTabIconSel")
    public static let splash = OilWhereImages(name: "splash")
    public static let splashLogo = OilWhereImages(name: "splashLogo")
  }
}

// MARK: - Implementation Details

public final class OilWhereColors: Sendable {
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

public extension OilWhereColors.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, visionOS 1.0, *)
  convenience init?(asset: OilWhereColors) {
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
  init(asset: OilWhereColors) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct OilWhereImages: Sendable {
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
  init(asset: OilWhereImages) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle)
  }

  init(asset: OilWhereImages, label: Text) {
    let bundle = Bundle.module
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: OilWhereImages) {
    let bundle = Bundle.module
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftformat:enable all
// swiftlint:enable all
