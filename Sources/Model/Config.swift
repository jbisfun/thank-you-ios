import FossifyCommons
import Foundation
import Observation

/// Port of the Thank You Config (SharedPreferences -> UserDefaults) plus the
/// "All Fossify apps" settings it writes to the global config; colors live in
/// FossifyCommons.BaseConfig.
@Observable
final class Config {
    static let shared = Config()

    /// Google Play builds thank the buyer; F-Droid/GitHub builds (like this port) ask for donations.
    static let isGooglePlayBuild = false

    @ObservationIgnored private let d = UserDefaults.standard

    var showThankYouNotice: Bool { didSet { d.set(showThankYouNotice, forKey: "show_thank_you_notice") } }

    // Global config (MyContentProvider): shared by every Fossify app in the launcher.
    var showCheckmarksOnSwitches: Bool {
        didSet { d.set(showCheckmarksOnSwitches, forKey: GlobalSettings.showCheckmarksOnSwitchesKey) }
    }
    var useBinaryStorageUnits: Bool {
        didSet { d.set(useBinaryStorageUnits, forKey: GlobalSettings.useBinaryStorageUnitsKey) }
    }

    private init() {
        showThankYouNotice = d.object(forKey: "show_thank_you_notice") as? Bool ?? true
        showCheckmarksOnSwitches = d.bool(forKey: GlobalSettings.showCheckmarksOnSwitchesKey)
        useBinaryStorageUnits = d.bool(forKey: GlobalSettings.useBinaryStorageUnitsKey)
    }
}
