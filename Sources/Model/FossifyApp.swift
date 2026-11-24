import FossifyCommons
import Foundation
import UIKit

/// models/FossifyApp.kt: one Fossify app shown on the main screen.
public struct FossifyApp: Identifiable {
    /// Handed to `launchApp`; the launcher's own app id.
    public var id: String
    public var name: String
    public var icon: UIImage?
    public var packageName: String
    public var versionName: String?
    public var signerName: String?
    public var installerName: String?
    /// Signed with the same certificate as this app (iOS: always, see README).
    public var verified: Bool

    public init(id: String, name: String, icon: UIImage?, packageName: String, versionName: String?,
                signerName: String?, installerName: String?, verified: Bool = true) {
        self.id = id
        self.name = name
        self.icon = icon
        self.packageName = packageName
        self.versionName = versionName
        self.signerName = signerName
        self.installerName = installerName
        self.verified = verified
    }

    /// `launchApp` id of Thank You itself: tapping it says hello instead.
    public static let thankYouID = AppInfo.thankYou.port

    /// An app bundled into the running binary (the launcher): it shares this
    /// bundle's identifier, version, signer and installer.
    public static func hosted(_ info: AppInfo, icon: UIImage?, versionName: String? = nil) -> FossifyApp {
        FossifyApp(id: info.port, name: info.name, icon: icon, packageName: Bundle.main.bundleIdentifier ?? info.port,
                   versionName: versionName ?? BundleSignature.version, signerName: BundleSignature.signer,
                   installerName: BundleSignature.installer)
    }

    /// The standalone app: getAllFossifyApps() can only ever see itself on iOS.
    static var current: FossifyApp {
        FossifyApp(id: thankYouID, name: Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Thank You",
                   icon: BundleSignature.appIcon, packageName: Bundle.main.bundleIdentifier ?? "org.fossify.thankyou.ios",
                   versionName: BundleSignature.version, signerName: BundleSignature.signer,
                   installerName: BundleSignature.installer)
    }
}

/// getSignerName / getInstallerPackage for the running bundle, from its
/// embedded provisioning profile (absent for App Store installs).
enum BundleSignature {
    static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String

    private static let profile: [String: Any]? = {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url),
              let start = data.range(of: Data("<?xml".utf8)),
              let end = data.range(of: Data("</plist>".utf8), in: start.lowerBound..<data.endIndex)
        else { return nil }
        let plist = data.subdata(in: start.lowerBound..<end.upperBound)
        return (try? PropertyListSerialization.propertyList(from: plist, format: nil)) as? [String: Any]
    }()

    /// Certificate organization (O=) ~ the profile's team name.
    static var signer: String? {
        if let team = profile?["TeamName"] as? String { return team }
        return isAppStore ? "Apple" : nil
    }

    static var installer: String? {
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt", profile == nil { return "TestFlight" }
        if isAppStore { return "App Store" }
        if profile?["ProvisionsAllDevices"] as? Bool == true { return "Enterprise" }
        return nil
    }

    private static var isAppStore: Bool {
        profile == nil && Bundle.main.appStoreReceiptURL.map { FileManager.default.fileExists(atPath: $0.path) } == true
    }

    static let appIcon: UIImage? = {
        let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any]
        let primary = icons?["CFBundlePrimaryIcon"] as? [String: Any]
        let files = primary?["CFBundleIconFiles"] as? [String]
        return files?.last.flatMap { UIImage(named: $0) } ?? UIImage(named: "AppIcon")
    }()
}
