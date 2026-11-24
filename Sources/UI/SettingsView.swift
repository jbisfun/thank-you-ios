import FossifyCommons
import SwiftUI

/// SettingsActivity / ui/screens/SettingsScreen.kt.
struct SettingsView: View {
    @Environment(Router.self) private var router
    @Environment(Config.self) private var config
    @Environment(\.palette) private var palette
    @State private var pickStorageUnits = false

    private static let decimalUnits = "Decimal (1 kB = 1,000 bytes)"
    private static let binaryUnits = "Binary (1 KiB = 1,024 bytes)"

    var body: some View {
        @Bindable var config = config
        VStack(spacing: 0) {
            TopBar(title: "Settings")
            ScrollView {
                VStack(spacing: 0) {
                    Text("Color customization").sectionHeader(palette)
                    SettingsItem("Customize colors") { router.push(.customizeColors) }

                    Divider().overlay(palette.divider).padding(.top, 8)
                    Text("All Fossify apps").sectionHeader(palette)
                    SettingsToggle("Show checkmarks on switches", isOn: $config.showCheckmarksOnSwitches)
                    SettingsItem("Storage units", value: config.useBinaryStorageUnits ? Self.binaryUnits : Self.decimalUnits) {
                        pickStorageUnits = true
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(palette.backgroundColor.ignoresSafeArea())
        .sheet(isPresented: $pickStorageUnits) {
            RadioDialog(title: "Storage units", items: [(false, Self.decimalUnits), (true, Self.binaryUnits)],
                        selected: config.useBinaryStorageUnits) { config.useBinaryStorageUnits = $0 }
        }
    }
}

extension AppInfo {
    public static let thankYou = AppInfo(
        name: "Thank You", icon: "heart.fill", upstream: "Thank-You", port: "thank-you-ios", policy: "thank-you"
    )
}
