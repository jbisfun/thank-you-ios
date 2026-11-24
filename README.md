# thank-you-ios

[Fossify Thank You](https://github.com/FossifyOrg/Thank-You) re-created for iOS in SwiftUI.

    idl build -c release     # -> build/release/FossifyThankYou.ipa (ad-hoc signed; re-sign to install)
    idl install "<device>" FossifyThankYou

Ported: the donation notice (F-Droid build) with the donation screen (platforms and crypto addresses, open or copy), the installed Fossify apps list with version, package, signer and installer (tap to open, "Hello :)" for itself); settings: colors, and the global "All Fossify apps" options shared with every app in the launcher, show checkmarks on switches and storage units (decimal/binary); about.

Differences forced by iOS: apps can't enumerate or inspect other installed apps, so the list shows this app standalone and the bundled apps inside the launcher, and "Potentially unsafe apps" (signature mismatch) and uninstalling don't exist; signer and installer come from the provisioning profile; no in-app language switch and no alternative launcher icons.

GPL-3.0, like the original.
