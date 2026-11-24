import FossifyCommons
import Observation
import SwiftUI

enum Route: Hashable {
    case settings
    case customizeColors
    case about
    case donate
}

@MainActor
@Observable
final class Router {
    var path: [Route] = []
    var toast: String?

    func push(_ r: Route) { path.append(r) }
}

/// The whole app as one view: the standalone app's window content, and what
/// the launcher presents.
public struct ThankYouRoot: View {
    @State private var router = Router()
    private let apps: [FossifyApp]?
    private let launchApp: ((String) -> Void)?

    /// - Parameters:
    ///   - apps: the Fossify apps to list (the launcher passes its bundled apps,
    ///     e.g. `.hosted(.calculator, icon: ...)`); nil lists this app only.
    ///   - launchApp: opens the app with the given `FossifyApp.id`.
    public init(apps: [FossifyApp]? = nil, launchApp: ((String) -> Void)? = nil) {
        self.apps = apps
        self.launchApp = launchApp
    }

    public var body: some View {
        RootView(apps: (apps ?? [.current]).sorted { $0.name.localizedCompare($1.name) == .orderedAscending },
                 launchApp: launchApp)
            .environment(router)
            .environment(Config.shared)
            .fossifyTheme()
    }
}

struct RootView: View {
    @Environment(Router.self) private var router
    let apps: [FossifyApp]
    let launchApp: ((String) -> Void)?

    var body: some View {
        @Bindable var router = router
        NavigationStack(path: $router.path) {
            MainView(apps: apps, launchApp: launchApp)
                .navigationDestination(for: Route.self) { route in
                    Group {
                        switch route {
                        case .settings: SettingsView()
                        case .customizeColors: CustomizeColorsView()
                        case .about: AboutView(app: .thankYou)
                        case .donate: DonationView()
                        }
                    }
                    .toolbar(.hidden, for: .navigationBar)
                    .paletteBackground()
                }
                .toolbar(.hidden, for: .navigationBar)
        }
        .toast($router.toast)
    }
}
