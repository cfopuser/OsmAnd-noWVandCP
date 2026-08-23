# OsmAnd+ Kiosk & SSL Packet Inspection Edition

[![Upstream Sync & Automated Build](https://github.com/cfopuser/OsmAnd-noWVandCP/actions/workflows/upstream-sync-and-build.yml/badge.svg)](https://github.com/cfopuser/OsmAnd-noWVandCP/actions/workflows/upstream-sync-and-build.yml)
[![Latest Release](https://img.shields.io/github/v/release/cfopuser/OsmAnd-noWVandCP?include_prereleases&label=Latest%20Release)](https://github.com/cfopuser/OsmAnd-noWVandCP/releases/latest)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

> **Maintained & Edited by [cfopuser](https://github.com/cfopuser)**  
> A dedicated hardened fork of **OsmAnd+** tailored for **Kiosk environments**, **device lockdown**, and **enterprise/filtered ISP networks**.

---

## 🎯 Fork Highlights & Key Features

### 1. 🔒 Kiosk Mode & Strict Web Lockdown
- **No In-App Web Browsing**: Embedded WebViews across settings, help articles, Wikipedia cards, and menus are locked down with network loads blocked (`setBlockNetworkLoads(true)`).
- **Zero Browser Breakout**: External URL intents (`http://`, `https://`) and CustomTabs launches (`openUrl`, `ACTION_VIEW`) are strictly intercepted and suppressed, displaying a toast (`Web browsing is disabled`).
- **Dynamic Runtime Enforcement**: `ActivityLifecycleCallbacks` recursively scan and sanitize inflated view hierarchies on any current or future screens at runtime.

### 2. 🛡️ SSL Packet Inspection & User CA Trust
- **Zero Certificate Pinning**: All hardcoded certificate pinning has been removed, ensuring network requests work seamlessly behind TLS-intercepting firewalls and content-filtering ISPs.
- **Android Network Security Config**: Declared OS-level `<trust-anchors>` with both `<certificates src="system" />` and `<certificates src="user" />` across all base and debug connections.

### 3. 🗺️ Full Native Navigation & 3D Offline Maps
- All core OsmAnd capabilities remain 100% functional without internet or Google Play dependencies:
  - 3D OpenGL vector map rendering (`OsmAndCore`).
  - Turn-by-turn offline voice routing.
  - Offline POI, address, and coordinate search.
  - Direct offline map downloads.

### 4. ⚡ Fully Automated CI/CD & Upstream Synchronization
- **Continuous Upstream Sync**: Automated GitHub Actions workflow checks out upstream `osmandapp/OsmAnd` and its sibling modules weekly.
- **Automated GitHub Releases**: Builds the universal APKs, computes `SHA256SUMS.txt`, and publishes releases directly to the **[Releases tab](https://github.com/cfopuser/OsmAnd-noWVandCP/releases)** under official version tags (e.g. `v5.4.0`).
- **Invariant Gate Tests**: Automated verification scripts (`scripts/verify_kiosk_invariants.sh` / `.ps1`) ensure no unguarded WebViews or pinning rules slip through during upstream rebases.

---

## 📥 Download & Installation

### Latest Releases
Download the pre-built APK from the **[GitHub Releases](https://github.com/cfopuser/OsmAnd-noWVandCP/releases/latest)** page.

#### Using GitHub CLI (`gh`):
```bash
gh release download --repo cfopuser/OsmAnd-noWVandCP --pattern "*.apk"
```

#### Direct Download via `wget`:
```bash
wget https://github.com/cfopuser/OsmAnd-noWVandCP/releases/latest/download/OsmAnd-androidFull-legacy-fat-debug.apk
```

#### Verify Integrity:
```bash
sha256sum -c SHA256SUMS.txt
```

---

## 🛠️ Verification & Invariants Testing

To verify kiosk lockdown and security invariants locally:

**Linux / macOS (Bash):**
```bash
chmod +x scripts/verify_kiosk_invariants.sh
./scripts/verify_kiosk_invariants.sh
```

**Windows (PowerShell):**
```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify_kiosk_invariants.ps1
```

---

## 📄 License & Attribution

- **Original Project**: OsmAnd is Copyright © 2010–2026 OsmAnd BV (Amstelveen, Netherlands) and is licensed under the **GNU General Public License v3 (GPLv3)**.
- **Kiosk & SSL Inspection Modifications**: Copyright © 2026 **cfopuser**. Modifications are licensed under the **GNU General Public License v3 (GPLv3)** in compliance with GPLv3 Section 5 (Conveying Modified Source Versions).
- For complete details, refer to [`LICENSE`](./LICENSE) and [`AUTHORS.md`](./AUTHORS.md).

---

## 🌍 General OsmAnd Capabilities

OsmAnd (OSM Automated Navigation Directions) is a map and navigation application with access to the free, worldwide, and high-quality OpenStreetMap (OSM) database.

- **Offline Vector Maps**: Turn-by-turn optical and voice navigation without roaming charges.
- **Routing**: Specialized vehicle, bicycle, pedestrian, and public transport modes.
- **OpenStreetMap Data**: High-quality crowd-sourced global map layers, contour lines, hillshades, and offline POI database.
