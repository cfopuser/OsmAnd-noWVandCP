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
