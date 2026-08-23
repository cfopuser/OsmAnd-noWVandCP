# OsmAnd+ (Kiosk & Filtered Networks Edition)

[![Upstream Sync & Automated Build](https://github.com/cfopuser/OsmAnd-noWVandCP/actions/workflows/upstream-sync-and-build.yml/badge.svg)](https://github.com/cfopuser/OsmAnd-noWVandCP/actions/workflows/upstream-sync-and-build.yml)
[![Latest Release](https://img.shields.io/github/v/release/cfopuser/OsmAnd-noWVandCP?include_prereleases&label=Latest%20Release)](https://github.com/cfopuser/OsmAnd-noWVandCP/releases/latest)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![App Store Catalog](https://img.shields.io/badge/App_Store-OsmAnd-rose.svg)](https://cfopuser.github.io/app-store/#app/osmand)

A fork of OsmAnd+ configured for kiosk deployments, content-filtered networks (NetFree, enterprise inspection proxies), and locked-down devices. Automatically tracked, built, and published from upstream releases.

- Web Catalog: [cfopuser.github.io/app-store/#app/osmand](https://cfopuser.github.io/app-store/#app/osmand)
- Releases: [github.com/cfopuser/OsmAnd-noWVandCP/releases](https://github.com/cfopuser/OsmAnd-noWVandCP/releases)

---

## Modifications

### Kiosk Mode and In-App Web Lockdown
- Embedded WebViews in settings, help, and articles have remote network loads disabled.
- External browser and CustomTab intents (`http://`, `https://`) are intercepted to prevent browser breakout.
- Dynamic lifecycle hooks sanitize WebViews inflated across screens at runtime.

### SSL Inspection & Custom CA Trust
- Zero certificate pinning: requests function normally behind content-filtering ISPs and TLS-decrypting proxies.
- Android Network Security Config enables trust for both system and user-installed CA certificates.

### Full Offline Functionality Preserved
- 3D OpenGL vector map rendering, offline navigation, voice routing, search, and map downloads work without Google Play dependencies.

### Automated CI/CD
- Weekly upstream synchronization with `osmandapp/OsmAnd`.
- Automatic build and publishing to GitHub Releases under matching upstream version tags.

---

## Downloads

Pre-built APKs and checksums are available on the [Releases](https://github.com/cfopuser/OsmAnd-noWVandCP/releases/latest) page and the [App Store Catalog](https://cfopuser.github.io/app-store/#app/osmand).

```bash
# Download via GitHub CLI
gh release download --repo cfopuser/OsmAnd-noWVandCP --pattern "*.apk"

# Verify SHA256 integrity
sha256sum -c SHA256SUMS.txt
```

---

## Verification

Run invariant checks to verify kiosk lockdown and security settings:

- Linux / macOS: `./scripts/verify_kiosk_invariants.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File scripts/verify_kiosk_invariants.ps1`

---

## License & Attribution

- Original OsmAnd: Copyright (c) 2010-2026 OsmAnd BV under GNU General Public License v3 (GPLv3).
- Fork Modifications: Copyright (c) 2026 cfopuser under GNU General Public License v3 (GPLv3).
- Refer to [LICENSE](LICENSE) and [AUTHORS.md](AUTHORS.md) for details.
