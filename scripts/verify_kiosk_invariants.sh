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
