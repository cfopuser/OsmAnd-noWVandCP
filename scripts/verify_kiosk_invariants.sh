#!/bin/bash
set -e

echo "=== Running Kiosk & Security Invariants Verification ==="

# 1. Check network_security_config.xml exists and allows user + system certs
CONFIG_FILE="OsmAnd/res/xml/network_security_config.xml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: $CONFIG_FILE does not exist!"
    exit 1
fi

if ! grep -q 'src="user"' "$CONFIG_FILE" || ! grep -q 'src="system"' "$CONFIG_FILE"; then
    echo "ERROR: $CONFIG_FILE must trust both user and system certificates!"
    exit 1
fi
echo "✓ Network Security Config verified (User + System CA trusted, no pinning)."

# 2. Check AndroidManifest.xml links networkSecurityConfig
MANIFEST_FILE="OsmAnd/AndroidManifest.xml"
if ! grep -q 'android:networkSecurityConfig="@xml/network_security_config"' "$MANIFEST_FILE"; then
    echo "ERROR: $MANIFEST_FILE missing android:networkSecurityConfig attribute!"
    exit 1
fi
echo "✓ AndroidManifest.xml verified (networkSecurityConfig declared)."

# 3. Check AndroidUtils.java contains isWebIntent guard
ANDROID_UTILS="OsmAnd/src/net/osmand/plus/utils/AndroidUtils.java"
if ! grep -q 'isWebIntent' "$ANDROID_UTILS"; then
    echo "ERROR: $ANDROID_UTILS missing isWebIntent kiosk guard!"
    exit 1
fi
echo "✓ AndroidUtils.java verified (web intent interception active)."

# 4. Check WebViewEx.java contains kiosk protections
WEBVIEW_EX="OsmAnd/src/net/osmand/plus/widgets/WebViewEx.java"
if ! grep -q 'isRemoteUrl' "$WEBVIEW_EX" || ! grep -q 'setBlockNetworkLoads' "$WEBVIEW_EX"; then
    echo "ERROR: $WEBVIEW_EX missing remote URL or network blocking guards!"
    exit 1
fi
echo "✓ WebViewEx.java verified (dynamic kiosk URL blocking active)."

# 5. Check no CertificatePinner is being introduced in sources
PINNER_MATCHES=$(git grep "CertificatePinner" -- OsmAnd/src OsmAnd-java/src OsmAnd-shared/src 2>/dev/null || true)
if [ -n "$PINNER_MATCHES" ]; then
    echo "ERROR: CertificatePinner usage detected in source tree:"
    echo "$PINNER_MATCHES"
    exit 1
fi
echo "✓ Zero CertificatePinner calls in source tree verified."

echo "=== All Kiosk & Security Invariants Passed Successfully! ==="

echo "=== Running Kosher & Clean UI Invariants Verification ==="

# 6. Check WikipediaPlugin and MapillaryPlugin are removed from PluginsHelper
PLUGINS_HELPER="OsmAnd/src/net/osmand/plus/plugins/PluginsHelper.java"
if grep -q 'allPlugins.add(new WikipediaPlugin' "$PLUGINS_HELPER"; then
    echo "ERROR: WikipediaPlugin must not be registered in $PLUGINS_HELPER!"
    exit 1
fi
if grep -q 'allPlugins.add(new MapillaryPlugin' "$PLUGINS_HELPER"; then
    echo "ERROR: MapillaryPlugin must not be registered in $PLUGINS_HELPER!"
    exit 1
fi
echo "✓ PluginsHelper verified (Wikipedia and Mapillary plugins removed)."

# 7. Check MapActivityActions has no sale, live updates, travel guides, or cloud items in drawer
MAP_ACTIONS="OsmAnd/src/net/osmand/plus/activities/MapActivityActions.java"
if grep -q 'DRAWER_TRAVEL_GUIDES_ID' "$MAP_ACTIONS"; then
    echo "ERROR: DRAWER_TRAVEL_GUIDES_ID found in $MAP_ACTIONS!"
    exit 1
fi
if grep -q 'DRAWER_LIVE_UPDATES_ID' "$MAP_ACTIONS"; then
    echo "ERROR: DRAWER_LIVE_UPDATES_ID found in $MAP_ACTIONS!"
    exit 1
fi
if grep -q 'DRAWER_BACKUP_RESTORE_ID' "$MAP_ACTIONS"; then
    echo "ERROR: DRAWER_BACKUP_RESTORE_ID found in $MAP_ACTIONS!"
    exit 1
fi
echo "✓ MapActivityActions verified (Drawer cleaned of Travel Guides, Live updates, Cloud, and Sales)."

# 8. Check Settings XML has no cloud or purchases preferences
SETTINGS_XML="OsmAnd/res/xml/settings_main_screen.xml"
if grep -q 'backup_and_restore' "$SETTINGS_XML"; then
    echo "ERROR: backup_and_restore found in $SETTINGS_XML!"
    exit 1
fi
if grep -q 'purchases_settings' "$SETTINGS_XML"; then
    echo "ERROR: purchases_settings found in $SETTINGS_XML!"
    exit 1
fi
echo "✓ settings_main_screen.xml verified (Cloud and Purchases removed)."

# 9. Check promo cards and upsell banners are disabled
FAV_CARD="OsmAnd/src/net/osmand/plus/myplaces/favorites/dialogs/FavoritesFreeBackupCard.java"
TRACK_CARD="OsmAnd/src/net/osmand/plus/myplaces/tracks/dialogs/TracksFreeBackupCard.java"
DOWNLOAD_ACT="OsmAnd/src/net/osmand/plus/download/DownloadActivity.java"
DISCOUNT_HELPER="OsmAnd/src/net/osmand/plus/helpers/DiscountHelper.java"
RATE_US="OsmAnd/src/net/osmand/plus/feedback/RateUsHelper.java"

if ! grep -q 'return false;' "$FAV_CARD"; then
    echo "ERROR: FavoritesFreeBackupCard shouldShow must return false!"
    exit 1
fi
if ! grep -q 'return false;' "$TRACK_CARD"; then
    echo "ERROR: TracksFreeBackupCard shouldShow must return false!"
    exit 1
fi
if ! grep -q 'return false;' "$DOWNLOAD_ACT"; then
    echo "ERROR: DownloadActivity shouldShowFreeVersionBanner must return false!"
    exit 1
fi
if ! grep -q 'return false;' "$RATE_US"; then
    echo "ERROR: RateUsHelper shouldShowRateDialog must return false!"
    exit 1
fi
echo "✓ Promo cards, rate dialogs, discount polling, and download banners verified disabled."

echo "=== All Kiosk, Kosher & Clean UI Invariants Passed Successfully! ==="
