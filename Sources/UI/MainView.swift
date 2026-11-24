import FossifyCommons
import SwiftUI
import UIKit

/// MainActivity / ui/screens/MainScreen.kt.
struct MainView: View {
    @Environment(Router.self) private var router
    @Environment(Config.self) private var config
    @Environment(\.palette) private var palette
    let apps: [FossifyApp]
    let launchApp: ((String) -> Void)?

    private static let mainText = "Thank you for supporting us!\n\nDrop us a line at \n hello@fossify.org,\n we'd love to hear all your feedback and suggestions.\n\n(Please keep the app installed to keep all app features unlocked)"
    private static let donationText = "Fossify is funded by users like you!\n\nYour donations fuel improvements and new features. We appreciate your support—please consider contributing!\n\nThank you!"

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                LazyVStack(spacing: 0) {
                    notice
                    // getFakeFossifyApps(): "Potentially unsafe apps" can't be detected on iOS.
                    if !apps.isEmpty {
                        Text("Installed Fossify apps")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(palette.primaryColor)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 28)
                            .padding(.bottom, 8)
                        ForEach(apps) { app in
                            FossifyAppRow(app: app) { launch(app) }
                        }
                    }
                }
                .padding(.bottom, 32)
                .animation(.default, value: config.showThankYouNotice)
            }
        }
        .background(palette.backgroundColor.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack(spacing: 0) {
            CloseAppButton()
            Text("Fossify Thank You")
                .font(.system(size: 20, weight: .bold))
                .lineLimit(1)
                .padding(.leading, 12)
            Spacer()
            IconButton(icon: "gearshape.fill") { router.push(.settings) }
            Menu {
                Button("About") { router.push(.about) }
                if Config.isGooglePlayBuild {
                    Button("More Fossify apps") { Launcher.open(URL(string: "https://www.fossify.org/apps")) }
                }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 19)).frame(width: 44, height: 48)
            }
        }
        .padding(.horizontal, 4)
        .frame(height: 56)
    }

    @ViewBuilder private var notice: some View {
        if Config.isGooglePlayBuild {
            if config.showThankYouNotice {
                MainNotice(text: Self.mainText, buttonText: "Do not show again") { config.showThankYouNotice = false }
            }
        } else {
            MainNotice(text: Self.donationText, buttonText: "Donate") { router.push(.donate) }
        }
    }

    private func launch(_ app: FossifyApp) {
        if app.id == FossifyApp.thankYouID {
            router.toast = "Hello :)"
        } else {
            launchApp?(app.id)
        }
    }
}

/// MainNotice: outlined card with linkified text and a trailing text button.
private struct MainNotice: View {
    @Environment(\.palette) private var palette
    let text: String
    let buttonText: String
    let onButton: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(Self.linkified(text))
                .font(.system(size: 16))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundStyle(palette.textColor)
                .tint(palette.primaryColor)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            Button(action: onButton) {
                Text(buttonText).font(.system(size: 15, weight: .semibold)).foregroundStyle(palette.primaryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(palette.divider))
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    /// Linkify.WEB_URLS | Linkify.EMAIL_ADDRESSES.
    static func linkified(_ text: String) -> AttributedString {
        var result = AttributedString(text)
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return result }
        for match in detector.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            guard let url = match.url, let range = Range(match.range, in: text),
                  let lower = AttributedString.Index(range.lowerBound, within: result),
                  let upper = AttributedString.Index(range.upperBound, within: result) else { continue }
            result[lower..<upper].link = url
        }
        return result
    }
}

/// ui/components/FossifyApp.kt: icon, name and version/package/signer/installer lines.
private struct FossifyAppRow: View {
    @Environment(\.palette) private var palette
    let app: FossifyApp
    let launch: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: launch) {
                HStack(alignment: .top, spacing: 16) {
                    icon.padding(.top, 4)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(app.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(app.verified ? palette.textColor : Color.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Group {
                            Text("Version: \(app.versionName ?? "Unknown")")
                            Text("Package: \(app.packageName)").lineLimit(1)
                            Text("Signed by: \(app.signerName ?? "Unknown")").lineLimit(1)
                            Text("Installed by: \(app.installerName ?? "Unknown")").lineLimit(1)
                        }
                        .font(.system(size: 14))
                        .foregroundStyle(palette.secondaryText)
                        .truncationMode(.tail)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!app.verified)
            Button(action: launch) {
                Image(systemName: "arrow.up.forward.square")
                    .font(.system(size: 20))
                    .foregroundStyle(palette.primaryColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Open")
        }
        .padding(.leading, 16)
        .padding(.trailing, 8)
        .padding(.vertical, 8)
    }

    private var icon: some View {
        Group {
            if let image = app.icon {
                Image(uiImage: image).resizable()
            } else {
                palette.primaryColor.overlay(
                    Image(systemName: AppInfo.thankYou.icon).font(.system(size: 20)).foregroundStyle(palette.onPrimary))
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}
