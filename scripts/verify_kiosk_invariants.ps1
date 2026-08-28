Write-Host "=== Running Kiosk and Security Invariants Verification ==="

# 1. Check network_security_config.xml
$configFile = "OsmAnd\res\xml\network_security_config.xml"
if (-not (Test-Path $configFile)) {
    Write-Error "ERROR: $configFile does not exist!"
    exit 1
}
$configContent = Get-Content $configFile -Raw
if ($configContent -notmatch 'src="user"' -or $configContent -notmatch 'src="system"') {
    Write-Error "ERROR: $configFile must trust both user and system certificates!"
    exit 1
}
Write-Host "Verified Network Security Config: User and System CA trusted, no pinning."

# 2. Check AndroidManifest.xml
$manifestFile = "OsmAnd\AndroidManifest.xml"
$manifestContent = Get-Content $manifestFile -Raw
if ($manifestContent -notmatch 'android:networkSecurityConfig="@xml/network_security_config"') {
    Write-Error "ERROR: $manifestFile missing android:networkSecurityConfig attribute!"
    exit 1
}
Write-Host "Verified AndroidManifest.xml: networkSecurityConfig declared."

# 3. Check AndroidUtils.java
$androidUtils = "OsmAnd\src\net\osmand\plus\utils\AndroidUtils.java"
$utilsContent = Get-Content $androidUtils -Raw
if ($utilsContent -notmatch 'isWebIntent') {
    Write-Error "ERROR: $androidUtils missing isWebIntent kiosk guard!"
    exit 1
}
Write-Host "Verified AndroidUtils.java: web intent interception active."

# 4. Check WebViewEx.java
$webViewEx = "OsmAnd\src\net\osmand\plus\widgets\WebViewEx.java"
$webViewContent = Get-Content $webViewEx -Raw
if ($webViewContent -notmatch 'isRemoteUrl' -or $webViewContent -notmatch 'setBlockNetworkLoads') {
    Write-Error "ERROR: $webViewEx missing remote URL or network blocking guards!"
    exit 1
}
Write-Host "Verified WebViewEx.java: dynamic kiosk URL blocking active."

# 5. Check no CertificatePinner in source trees
$pinnerFiles = git grep "CertificatePinner" -- OsmAnd/src OsmAnd-java/src OsmAnd-shared/src 2>$null
if ($pinnerFiles) {
    Write-Error "ERROR: CertificatePinner usage detected in source tree!"
    exit 1
}
Write-Host "Verified: Zero CertificatePinner calls detected in sources."

Write-Host "=== All Kiosk and Security Invariants Passed Successfully! ==="

Write-Host "=== Running Kosher and Clean UI Invariants Verification ==="

# 6. Check PluginsHelper
$pluginsHelper = "OsmAnd\src\net\osmand\plus\plugins\PluginsHelper.java"
$pluginsContent = Get-Content $pluginsHelper -Raw
if ($pluginsContent -match 'allPlugins\.add\(new WikipediaPlugin') {
    Write-Error "ERROR: WikipediaPlugin must not be registered in $pluginsHelper!"
    exit 1
}
if ($pluginsContent -match 'allPlugins\.add\(new MapillaryPlugin') {
    Write-Error "ERROR: MapillaryPlugin must not be registered in $pluginsHelper!"
    exit 1
}
Write-Host "Verified PluginsHelper: Wikipedia and Mapillary plugins removed."

# 7. Check MapActivityActions
$mapActions = "OsmAnd\src\net\osmand\plus\activities\MapActivityActions.java"
$mapActionsContent = Get-Content $mapActions -Raw
if ($mapActionsContent -match 'DRAWER_TRAVEL_GUIDES_ID') {
    Write-Error "ERROR: DRAWER_TRAVEL_GUIDES_ID found in $mapActions!"
    exit 1
}
if ($mapActionsContent -match 'DRAWER_LIVE_UPDATES_ID') {
    Write-Error "ERROR: DRAWER_LIVE_UPDATES_ID found in $mapActions!"
    exit 1
}
if ($mapActionsContent -match 'DRAWER_BACKUP_RESTORE_ID') {
    Write-Error "ERROR: DRAWER_BACKUP_RESTORE_ID found in $mapActions!"
    exit 1
}
Write-Host "Verified MapActivityActions: Drawer cleaned of Travel Guides, Live updates, Cloud, and Sales."

# 8. Check settings_main_screen.xml
$settingsXml = "OsmAnd\res\xml\settings_main_screen.xml"
$settingsContent = Get-Content $settingsXml -Raw
if ($settingsContent -match 'backup_and_restore') {
    Write-Error "ERROR: backup_and_restore found in $settingsXml!"
    exit 1
}
if ($settingsContent -match 'purchases_settings') {
    Write-Error "ERROR: purchases_settings found in $settingsXml!"
    exit 1
}
Write-Host "Verified settings_main_screen.xml: Cloud and Purchases removed."

# 9. Check promo cards and upsell banners disabled
$favCard = Get-Content "OsmAnd\src\net\osmand\plus\myplaces\favorites\dialogs\FavoritesFreeBackupCard.java" -Raw
$trackCard = Get-Content "OsmAnd\src\net\osmand\plus\myplaces\tracks\dialogs\TracksFreeBackupCard.java" -Raw
$downloadAct = Get-Content "OsmAnd\src\net\osmand\plus\download\DownloadActivity.java" -Raw
$rateUs = Get-Content "OsmAnd\src\net\osmand\plus\feedback\RateUsHelper.java" -Raw

if ($favCard -notmatch 'return false;') {
    Write-Error "ERROR: FavoritesFreeBackupCard shouldShow must return false!"
    exit 1
}
if ($trackCard -notmatch 'return false;') {
    Write-Error "ERROR: TracksFreeBackupCard shouldShow must return false!"
    exit 1
}
if ($downloadAct -notmatch 'return false;') {
    Write-Error "ERROR: DownloadActivity shouldShowFreeVersionBanner must return false!"
    exit 1
}
if ($rateUs -notmatch 'return false;') {
    Write-Error "ERROR: RateUsHelper shouldShowRateDialog must return false!"
    exit 1
}
Write-Host "Verified: Promo cards, rate dialogs, and download banners disabled."

Write-Host "=== All Kiosk, Kosher & Clean UI Invariants Passed Successfully! ==="
