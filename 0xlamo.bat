<# ::
:: 0xlaMo - Windows Tweaker Tool
:: Combines the best from Optimizer, Winhance & Win11Debloat
:: Made by 0xlamo
:: Works in both CMD and PowerShell
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Get-Content '%~f0' -Raw)"
pause
exit /b
#>

$script:Version = "1.0"
$script:Author = "0xlamo"
$script:SaveFile = Join-Path $env:USERPROFILE "Desktop\0xlaMo_Results.txt"
$script:Changes = @()
$script:Log = @()

function Show-Splash {
    Clear-Host
    $text = "0xla,mo"
    $colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta", "White")
    $i = 0
    foreach ($char in $text.ToCharArray()) {
        Write-Host $char -NoNewline -ForegroundColor $colors[$i % $colors.Length]
        Start-Sleep -Milliseconds 150
        $i++
    }
    Start-Sleep -Milliseconds 300
    Write-Host ""
    Write-Host ""
    Write-Host "Made by " -NoNewline
    Start-Sleep -Milliseconds 200
    Write-Host "0xlamo" -ForegroundColor Cyan -NoNewline
    Start-Sleep -Milliseconds 200
    Write-Host " | v$Version" -ForegroundColor DarkGray
    Start-Sleep -Milliseconds 400
    Write-Host ""
    Write-Host "[==================================================]" -ForegroundColor DarkGray
    Write-Host "  Windows Tweaker Tool - Optimizer + Winhance + Win11Debloat" -ForegroundColor Gray
    Write-Host "[==================================================]" -ForegroundColor DarkGray
    Write-Host ""
    Start-Sleep -Milliseconds 500
}

function Write-Log {
    param([string]$Msg)
    $script:Log += "[$(Get-Date -Format 'HH:mm:ss')] $Msg"
}

function Add-Change {
    param([string]$Category, [string]$Action, [string]$Status)
    $script:Changes += @{
        Category = $Category
        Action   = $Action
        Status   = $Status
        Time     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    Write-Log "[$Category] $Action - $Status"
}

function Save-Results {
    $sb = @"
=============================================
 0xlaMo - Windows Tweaker Tool
 Made by 0xlamo | v$Version
=============================================
 Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
 User: $env:USERNAME
 System: $((Get-CimInstance Win32_OperatingSystem).Caption)
=============================================

Summary of Changes:
---------------------------------------------
"@

    if ($script:Changes.Count -eq 0) {
        $sb += " No changes were made.`n"
    } else {
        $grouped = $script:Changes | Group-Object Category
        foreach ($g in $grouped) {
            $sb += "`n[$($g.Name)]`n"
            $sb += "-"*50 + "`n"
            foreach ($c in $g.Group) {
                $statusSymbol = if ($c.Status -eq "Success") { "[OK]" } else { "[FAIL]" }
                $sb += "  $statusSymbol $($c.Action)`n"
            }
        }
    }

    $sb += @"

=============================================
 Detailed Log:
---------------------------------------------
"@
    foreach ($line in $script:Log) {
        $sb += "  $line`n"
    }

    $sb += @"

=============================================
 End of Report
=============================================
"@

    Set-Content -Path $script:SaveFile -Value $sb -Encoding UTF8
    Write-Host ""
    Write-Host " [SAVED] Results saved to: $($script:SaveFile)" -ForegroundColor Green
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Require-Admin {
    if (-not (Test-Admin)) {
        Write-Host " [!] This operation requires Administrator privileges!" -ForegroundColor Red
        Write-Host ""
        $choice = Read-Host " Restart as Administrator? (y/n)"
        if ($choice -match '^[Yy]$') {
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
        return $false
    }
    return $true
}

function Show-MainMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ==================== MAIN MENU ====================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  Privacy & Telemetry" -ForegroundColor Yellow
    Write-Host "  2)  System Performance" -ForegroundColor Yellow
    Write-Host "  3)  App Removal (Bloatware)" -ForegroundColor Yellow
    Write-Host "  4)  Customization (Taskbar, Start, Explorer)" -ForegroundColor Yellow
    Write-Host "  5)  Windows Updates" -ForegroundColor Yellow
    Write-Host "  6)  Network & DNS" -ForegroundColor Yellow
    Write-Host "  7)  Advanced Tools" -ForegroundColor Yellow
    Write-Host "  8)  Apply All Recommended Tweaks" -ForegroundColor Green
    Write-Host "  9)  View Summary & Save" -ForegroundColor Magenta
    Write-Host "  0)  Exit" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Changes queued: $($script:Changes.Count)" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-PrivacyMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ============= PRIVACY & TELEMETRY =============" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  Disable Telemetry & Diagnostic Data" -ForegroundColor White
    Write-Host "  2)  Disable Cortana" -ForegroundColor White
    Write-Host "  3)  Disable CoPilot AI & Recall" -ForegroundColor White
    Write-Host "  4)  Disable Activity History & Tracking" -ForegroundColor White
    Write-Host "  5)  Disable Location Services" -ForegroundColor White
    Write-Host "  6)  Disable Ads & Suggestions" -ForegroundColor White
    Write-Host "  7)  Disable Office Telemetry" -ForegroundColor White
    Write-Host "  8)  Disable Windows Store Suggestions" -ForegroundColor White
    Write-Host "  9)  Apply ALL Privacy Tweaks" -ForegroundColor Green
    Write-Host "  B)  Back to Main Menu" -ForegroundColor Red
    Write-Host ""
}

function Show-PerformanceMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ============= SYSTEM PERFORMANCE ==============" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  Disable Unnecessary Services" -ForegroundColor White
    Write-Host "  2)  Gaming Optimizations (GPU, Timer)" -ForegroundColor White
    Write-Host "  3)  Disable HPET (High Precision Timer)" -ForegroundColor White
    Write-Host "  4)  Power Settings (Ultimate Performance)" -ForegroundColor White
    Write-Host "  5)  Disable Startup Programs" -ForegroundColor White
    Write-Host "  6)  Disable Animations & Transparency" -ForegroundColor White
    Write-Host "  7)  Disable Mouse Acceleration" -ForegroundColor White
    Write-Host "  8)  Disable Sticky Keys" -ForegroundColor White
    Write-Host "  9)  Apply ALL Performance Tweaks" -ForegroundColor Green
    Write-Host "  B)  Back to Main Menu" -ForegroundColor Red
    Write-Host ""
}

function Show-AppRemovalMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ============= APP REMOVAL (BLOATWARE) ===========" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  Remove Pre-installed Bloatware (Recommended)" -ForegroundColor White
    Write-Host "  2)  Remove Xbox & Gaming Apps" -ForegroundColor White
    Write-Host "  3)  Remove OneDrive" -ForegroundColor White
    Write-Host "  4)  Remove Microsoft Edge (Force)" -ForegroundColor White
    Write-Host "  5)  Remove All Non-Essential UWP Apps" -ForegroundColor White
    Write-Host "  6)  Remove HP Bloatware" -ForegroundColor White
    Write-Host "  7)  Reinstall Missing Store Apps" -ForegroundColor White
    Write-Host "  8)  Show Installed Apps List" -ForegroundColor Gray
    Write-Host "  B)  Back to Main Menu" -ForegroundColor Red
    Write-Host ""
}

function Show-CustomizeMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ============= CUSTOMIZATION ===============" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  Enable Dark Mode" -ForegroundColor White
    Write-Host "  2)  Taskbar: Align Left" -ForegroundColor White
    Write-Host "  3)  Taskbar: Hide Search, Widgets, Chat" -ForegroundColor White
    Write-Host "  4)  Taskbar: Never Combine Icons" -ForegroundColor White
    Write-Host "  5)  Taskbar: Enable End Task option" -ForegroundColor White
    Write-Host "  6)  Start Menu: Remove Recommended" -ForegroundColor White
    Write-Host "  7)  Start Menu: Remove Bing Search" -ForegroundColor White
    Write-Host "  8)  Explorer: Show Hidden Files & Extensions" -ForegroundColor White
    Write-Host "  9)  Explorer: Old Context Menu (Win11)" -ForegroundColor White
    Write-Host "  10) File Explorer: Hide Gallery, Home" -ForegroundColor White
    Write-Host "  11) Apply ALL Customization Tweaks" -ForegroundColor Green
    Write-Host "  B)  Back to Main Menu" -ForegroundColor Red
    Write-Host ""
}

function Show-UpdateMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ============= WINDOWS UPDATES ===============" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  Disable Automatic Updates" -ForegroundColor White
    Write-Host "  2)  Disable Update ASAP (Preview)" -ForegroundColor White
    Write-Host "  3)  Prevent Automatic Reboot" -ForegroundColor White
    Write-Host "  4)  Disable Delivery Optimization (P2P)" -ForegroundColor White
    Write-Host "  5)  Disable Fast Startup" -ForegroundColor White
    Write-Host "  6)  Disable BitLocker Auto-Encryption" -ForegroundColor White
    Write-Host "  7)  Disable Modern Standby Network" -ForegroundColor White
    Write-Host "  8)  Disable Storage Sense" -ForegroundColor White
    Write-Host "  9)  Apply ALL Update Tweaks" -ForegroundColor Green
    Write-Host "  B)  Back to Main Menu" -ForegroundColor Red
    Write-Host ""
}

function Show-NetworkMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ============= NETWORK & DNS =================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  Change DNS to Cloudflare (1.1.1.1)" -ForegroundColor White
    Write-Host "  2)  Change DNS to Google (8.8.8.8)" -ForegroundColor White
    Write-Host "  3)  Change DNS to OpenDNS" -ForegroundColor White
    Write-Host "  4)  Change DNS to Quad9" -ForegroundColor White
    Write-Host "  5)  Flush DNS Cache" -ForegroundColor White
    Write-Host "  6)  Disable IPv6" -ForegroundColor White
    Write-Host "  7)  Reset Network Stack" -ForegroundColor White
    Write-Host "  B)  Back to Main Menu" -ForegroundColor Red
    Write-Host ""
}

function Show-AdvancedMenu {
    Clear-Host
    Write-Host ""
    Write-Host "  ============= ADVANCED TOOLS ================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1)  System Cleanup (Disk Cleanup)" -ForegroundColor White
    Write-Host "  2)  Registry Cleanup & Fixes" -ForegroundColor White
    Write-Host "  3)  HOSTS File - Block Trackers" -ForegroundColor White
    Write-Host "  4)  System Information" -ForegroundColor White
    Write-Host "  5)  Create System Restore Point" -ForegroundColor White
    Write-Host "  6)  Enable/Disable UAC" -ForegroundColor White
    Write-Host "  7)  Enable UTC Time (Dual Boot)" -ForegroundColor White
    Write-Host "  8)  Disable Windows Defender (Safe Mode)" -ForegroundColor White
    Write-Host "  B)  Back to Main Menu" -ForegroundColor Red
    Write-Host ""
}

# ====== PRIVACY TWEAKS ======

function Disable-Telemetry {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Telemetry..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MaxTelemetryAllowed" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "MicrosoftEdgeDataOptIn" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    if (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection") {
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowUpdateComplianceProcessing" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowCommercialDataPipeline" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallOff" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallOff2016" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable 2>$null
    schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /Disable 2>$null
    
    Add-Change -Category "Privacy" -Action "Disable Telemetry & Diagnostic Data" -Status "Success"
    Write-Host " [OK] Telemetry disabled" -ForegroundColor Green
}

function Disable-Cortana {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Cortana..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortanaAboveLock" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Privacy" -Action "Disable Cortana" -Status "Success"
    Write-Host " [OK] Cortana disabled" -ForegroundColor Green
}

function Disable-CopilotAI {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling CoPilot AI & Recall..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "CopilotEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableRecall" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Recall" -Name "AllowStore" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Set-Service -Name "WSAIFabricSvc" -StartupType Disabled -ErrorAction SilentlyContinue
    sc.exe stop WSAIFabricSvc 2>$null
    
    Get-AppxPackage -Name "*Copilot*" | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "*Copilot*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    
    Add-Change -Category "Privacy" -Action "Disable CoPilot AI & Recall" -Status "Success"
    Write-Host " [OK] CoPilot AI & Recall disabled" -ForegroundColor Green
}

function Disable-ActivityHistory {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Activity History..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Privacy" -Action "Disable Activity History & Tracking" -Status "Success"
    Write-Host " [OK] Activity History disabled" -ForegroundColor Green
}

function Disable-LocationServices {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Location Services..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocationScripting" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Privacy" -Action "Disable Location Services" -Status "Success"
    Write-Host " [OK] Location Services disabled" -ForegroundColor Green
}

function Disable-AdsSuggestions {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Ads & Suggestions..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContentEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "AdvertisingId" -Type String -Value "" -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Privacy" -Action "Disable Ads & Suggestions" -Status "Success"
    Write-Host " [OK] Ads & Suggestions disabled" -ForegroundColor Green
}

function Disable-OfficeTelemetry {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Office Telemetry..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common" -Name "disabletelemetry" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common" -Name "updatereliabilitydata" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\feedback" -Name "enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\feedback" -Name "includescreenshot" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\research\translation" -Name "disableonline translation" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\Common\ClientTelemetry" -Name "DisableTelemetry" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Feedback" -Name "Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Office\16.0\Common\Feedback" -Name "IncludeScreenshot" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Privacy" -Action "Disable Office Telemetry" -Status "Success"
    Write-Host " [OK] Office Telemetry disabled" -ForegroundColor Green
}

function Disable-StoreSuggestions {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Store Suggestions..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "AutoDownload" -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "RequirePrivacyURL" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-314563Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Privacy" -Action "Disable Windows Store Suggestions" -Status "Success"
    Write-Host " [OK] Store Suggestions disabled" -ForegroundColor Green
}

function Apply-AllPrivacy {
    Disable-Telemetry
    Disable-Cortana
    Disable-CopilotAI
    Disable-ActivityHistory
    Disable-LocationServices
    Disable-AdsSuggestions
    Disable-OfficeTelemetry
    Disable-StoreSuggestions
    Write-Host ""
    Write-Host " [DONE] All Privacy tweaks applied!" -ForegroundColor Green
}

# ====== PERFORMANCE TWEAKS ======

function Disable-Services {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling unnecessary services..." -ForegroundColor Yellow
    
    $services = @(
        @{Name="DiagTrack"; Display="Diagnostics Tracking Service"},
        @{Name="dmwappushservice"; Display="Device Management WAP Push"},
        @{Name="WMPNetworkSvc"; Display="Windows Media Player Network Sharing"},
        @{Name="RemoteRegistry"; Display="Remote Registry"},
        @{Name="SharedAccess"; Display="Internet Connection Sharing (ICS)"},
        @{Name="TabletInputService"; Display="Touch Keyboard & Handwriting"},
        @{Name="SessionEnv"; Display="Remote Desktop Configuration"},
        @{Name="TermService"; Display="Remote Desktop Services"},
        @{Name="UmRdpService"; Display="Remote Desktop USB Redirector"},
        @{Name="lfsvc"; Display="Geolocation Service"},
        @{Name="MapsBroker"; Display="Downloaded Maps Manager"},
        @{Name="WlanSvc"; Display="WLAN AutoConfig (if not needed)"},
        @{Name="XblAuthManager"; Display="Xbox Live Auth Manager"},
        @{Name="XblGameSave"; Display="Xbox Live Game Save"},
        @{Name="XboxNetApiSvc"; Display="Xbox Live Networking"},
        @{Name="XboxGipSvc"; Display="Xbox Accessory Management"},
        @{Name="WerSvc"; Display="Windows Error Reporting"},
        @{Name="WSearch"; Display="Windows Search"}
    )
    
    $count = 0
    foreach ($svc in $services) {
        $s = Get-Service -Name $svc.Name -ErrorAction SilentlyContinue
        if ($s -and $s.StartType -ne "Disabled") {
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
            $count++
            Write-Host "    - $($svc.Display): Disabled" -ForegroundColor Gray
        }
    }
    
    Add-Change -Category "Performance" -Action "Disable Unnecessary Services ($count disabled)" -Status "Success"
    Write-Host " [OK] $count services disabled" -ForegroundColor Green
}

function Enable-GamingOptimizations {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Applying gaming optimizations..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 4294967295 -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AllowAutoGameMode" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "HistoricalCaptureEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Performance" -Action "Gaming Optimizations (GPU, Game Mode)" -Status "Success"
    Write-Host " [OK] Gaming optimizations applied" -ForegroundColor Green
}

function Disable-HPET {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling HPET..." -ForegroundColor Yellow
    
    bcdedit /deletevalue useplatformclock 2>$null
    bcdedit /set tscsyncpolicy Enhanced 2>$null
    bcdedit /set disabledynamictick Yes 2>$null
    
    Add-Change -Category "Performance" -Action "Disable HPET (High Precision Timer)" -Status "Success"
    Write-Host " [OK] HPET disabled" -ForegroundColor Green
}

function Set-PowerSettings {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Configuring power settings..." -ForegroundColor Yellow
    
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    
    $plans = powercfg /list
    $highPerf = $plans | Select-String "High performance" | Select-Object -First 1
    if ($highPerf) {
        $guid = ($highPerf -split '\s+')[3]
        powercfg /setactive $guid 2>$null
    }
    
    powercfg -change -disk-timeout-ac 0 2>$null
    powercfg -change -disk-timeout-dc 0 2>$null
    powercfg -change -monitor-timeout-ac 15 2>$null
    powercfg -change -monitor-timeout-dc 15 2>$null
    powercfg -change -standby-timeout-ac 0 2>$null
    powercfg -change -standby-timeout-dc 0 2>$null
    powercfg -change -hibernate-timeout-ac 0 2>$null
    powercfg -change -hibernate-timeout-dc 0 2>$null
    powercfg /hibernate off 2>$null
    
    Add-Change -Category "Performance" -Action "Power Settings (High Performance)" -Status "Success"
    Write-Host " [OK] Power settings configured" -ForegroundColor Green
}

function Disable-Startups {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Managing startup programs..." -ForegroundColor Yellow
    
    $disabled = @(
        "OneDriveSetup",
        "MicrosoftEdgeUpdate",
        "AdobeGCInvoker",
        "Spotify",
        "Discord",
        "Steam",
        "Teams",
        "Skype",
        "Zoom",
        "Slack",
        "TelegramDesktop",
        "WhatsApp",
        "Docker Desktop",
        "Evernote"
        "SunJava"
    )
    
    $count = 0
    Get-CimInstance Win32_StartupCommand | ForEach-Object {
        $name = $_.Name
        foreach ($d in $disabled) {
            if ($name -like "*$d*") {
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name $name -ErrorAction SilentlyContinue
                Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name $name -ErrorAction SilentlyContinue
                $count++
            }
        }
    }
    
    Add-Change -Category "Performance" -Action "Disable Startup Programs ($count removed)" -Status "Success"
    Write-Host " [OK] $count startup entries removed" -ForegroundColor Green
}

function Disable-Animations {
    Write-Host " [+] Disabling animations & transparency..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "EnableTransparency" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Performance" -Action "Disable Animations & Transparency" -Status "Success"
    Write-Host " [OK] Animations & transparency disabled" -ForegroundColor Green
}

function Disable-MouseAcceleration {
    Write-Host " [+] Disabling mouse acceleration..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Type String -Value "0" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Type String -Value "0" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Type String -Value "0" -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Performance" -Action "Disable Mouse Acceleration" -Status "Success"
    Write-Host " [OK] Mouse acceleration disabled" -ForegroundColor Green
}

function Disable-StickyKeys {
    Write-Host " [+] Disabling Sticky Keys shortcut..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Type String -Value "58" -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\FilterKeys" -Name "Flags" -Type String -Value "122" -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Performance" -Action "Disable Sticky Keys" -Status "Success"
    Write-Host " [OK] Sticky Keys disabled" -ForegroundColor Green
}

function Apply-AllPerformance {
    Disable-Services
    Enable-GamingOptimizations
    Disable-HPET
    Set-PowerSettings
    Disable-Startups
    Disable-Animations
    Disable-MouseAcceleration
    Disable-StickyKeys
    Write-Host ""
    Write-Host " [DONE] All Performance tweaks applied!" -ForegroundColor Green
}

# ====== APP REMOVAL ======

function Remove-Bloatware {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Removing pre-installed bloatware..." -ForegroundColor Yellow
    
    $bloatware = @(
        "Microsoft.BingWeather"
        "Microsoft.BingNews"
        "Microsoft.BingSports"
        "Microsoft.BingFinance"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MixedReality.Portal"
        "Microsoft.Office.OneNote"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.SkypeApp"
        "Microsoft.Wallet"
        "Microsoft.WindowsAlarms"
        "Microsoft.WindowsCamera"
        "Microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.YourPhone"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.Advertising.Xaml"
        "Microsoft.MSPaint"
        "Microsoft.WindowsCalculator"
        "Microsoft.WindowsStore"
        "Microsoft.PowerAutomateDesktop"
        "Microsoft.Todos"
        "Microsoft.Windows.DevHome"
        "MicrosoftCorporationII.QuickAssist"
        "Clipchamp.Clipchamp"
        "Disney.37853FC22B2CE"
        "Duolingo.LearnLanguageESL"
        "Facebook.289ADDC2E6B2E"
        "Instagram.Instagram"
        "SpotifyAB.SpotifyMusic"
        "TikTok.TikTok"
        "Netflix.Netflix"
    )
    
    $count = 0
    foreach ($app in $bloatware) {
        $pkg = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
        if ($pkg) {
            Remove-AppxPackage -Package $pkg -ErrorAction SilentlyContinue
            $count++
        }
        $provisioned = Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like "$app*" -ErrorAction SilentlyContinue
        if ($provisioned) {
            Remove-AppxProvisionedPackage -Online -PackageName $provisioned.PackageName -ErrorAction SilentlyContinue
        }
    }
    
    Add-Change -Category "AppRemoval" -Action "Remove Pre-installed Bloatware ($count removed)" -Status "Success"
    Write-Host " [OK] $count bloatware apps removed" -ForegroundColor Green
}

function Remove-XboxApps {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Removing Xbox & Gaming apps..." -ForegroundColor Yellow
    
    $xbox = @(
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameCallableUI"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.GamingServices"
    )
    
    $count = 0
    foreach ($app in $xbox) {
        $pkg = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
        if ($pkg) {
            Remove-AppxPackage -Package $pkg -ErrorAction SilentlyContinue
            $count++
        }
    }
    
    $svcs = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc")
    foreach ($s in $svcs) {
        Set-Service -Name $s -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
    }
    
    Add-Change -Category "AppRemoval" -Action "Remove Xbox & Gaming Apps ($count removed)" -Status "Success"
    Write-Host " [OK] $count Xbox apps removed" -ForegroundColor Green
}

function Remove-OneDrive {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Removing OneDrive..." -ForegroundColor Yellow
    
    Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    
    $onedrivePath = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
    if (Test-Path $onedrivePath) {
        Start-Process -FilePath $onedrivePath -ArgumentList "/uninstall" -NoNewWindow -Wait
    }
    $onedrivePath64 = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
    if (Test-Path $onedrivePath64) {
        Start-Process -FilePath $onedrivePath64 -ArgumentList "/uninstall" -NoNewWindow -Wait
    }
    
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    $folders = @(
        "$env:LOCALAPPDATA\Microsoft\OneDrive",
        "$env:PROGRAMDATA\Microsoft OneDrive",
        "$env:SYSTEMDRIVE\OneDriveTemp"
    )
    foreach ($f in $folders) {
        if (Test-Path $f) {
            Remove-Item -Path $f -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    Add-Change -Category "AppRemoval" -Action "Remove OneDrive" -Status "Success"
    Write-Host " [OK] OneDrive removed" -ForegroundColor Green
}

function Remove-Edge {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Removing Microsoft Edge..." -ForegroundColor Yellow
    Write-Host " [!] This is a major change. Use with caution!" -ForegroundColor Red
    
    $choice = Read-Host " Are you sure? (y/n)"
    if ($choice -notmatch '^[Yy]$') { Write-Host " Skipped." -ForegroundColor DarkGray; return }
    
    $edgePath = "$env:PROGRAMFILES (x86)\Microsoft\Edge\Application"
    $setupPath = ""
    
    if (Test-Path "$edgePath\*\Installer\setup.exe") {
        $setupPath = (Get-ChildItem "$edgePath\*\Installer\setup.exe" | Select-Object -First 1).FullName
    }
    
    if ($setupPath) {
        $cmd = "`"$setupPath`" --uninstall --system-level --force-uninstall"
        Invoke-Expression $cmd 2>$null
    }
    
    $edgeFolders = @(
        "$env:LOCALAPPDATA\Microsoft\Edge",
        "$env:APPDATA\Microsoft\Edge",
        "$env:PROGRAMFILES (x86)\Microsoft\Edge",
        "$env:PROGRAMFILES\Microsoft\Edge"
    )
    
    foreach ($f in $edgeFolders) {
        if (Test-Path $f) { Remove-Item -Path $f -Recurse -Force -ErrorAction SilentlyContinue }
    }
    
    Add-Change -Category "AppRemoval" -Action "Remove Microsoft Edge" -Status "Success"
    Write-Host " [OK] Microsoft Edge removed" -ForegroundColor Green
}

function Remove-AllUWP {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Removing all non-essential UWP apps..." -ForegroundColor Yellow
    
    $exclude = @(
        "Microsoft.WindowsStore"
        "Microsoft.WindowsCalculator"
        "Microsoft.WindowsCamera"
        "Microsoft.Windows.Photos"
        "Microsoft.WindowsNotepad"
        "Microsoft.Paint"
        "Microsoft.ScreenSketch"
        "Microsoft.StorePurchaseApp"
        "Microsoft.DesktopAppInstaller"
        "Microsoft.UI.Xaml"
        "Microsoft.VCLibs"
        "Microsoft.NET.Native"
        "Microsoft.Services.Store.Engagement"
    )
    
    $count = 0
    Get-AppxPackage -AllUsers | Where-Object {
        $name = $_.Name
        $exclude -notcontains $name -and
        $name -notlike "*UI.Xaml*" -and
        $name -notlike "*VCLibs*" -and
        $name -notlike "*.NET.Native*" -and
        $name -notlike "*Services.Store*" -and
        $name -notlike "*DesktopAppInstaller*"
    } | ForEach-Object {
        Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
        $count++
    }
    
    Add-Change -Category "AppRemoval" -Action "Remove All Non-Essential UWP Apps ($count removed)" -Status "Success"
    Write-Host " [OK] $count UWP apps removed" -ForegroundColor Green
}

function Remove-HPBloat {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Removing HP Bloatware..." -ForegroundColor Yellow
    
    $hpApps = @(
        "AD2F1837.HPQuickDrop"
        "AD2F1837.HPSupportAssistant"
        "AD2F1837.myHP"
        "AD2F1837.HPPrivacySettings"
        "AD2F1837.HPClientSecurityManager"
        "AD2F1837.HPCertificate"
        "AD2F1837.HPHardwareDiagnostics"
        "AD2F1837.HPPowerManager"
        "AD2F1837.HPQuickTouch"
        "AD2F1837.HPSystemInformation"
        "AD2F1837.HPNetworkCheck"
        "AD2F1837.HPDisplayControl"
        "AD2F1837.HPAudioControl"
        "AD2F1837.HPQuickWeb"
        "AD2F1837.HPConnectionOptimizer"
        "AD2F1837.HPWorkWell"
        "AD2F1837.HPJumpStart"
        "AD2F1837.HPNotebook"
        "AD2F1837.HPPower"
        "AD2F1837.HPSecurity"
        "AD2F1837.HPSystemEventUtility"
        "AD2F1837.HPWake"
    )
    
    $count = 0
    foreach ($app in $hpApps) {
        $pkg = Get-AppxPackage -Name $app -ErrorAction SilentlyContinue
        if ($pkg) {
            Remove-AppxPackage -Package $pkg -ErrorAction SilentlyContinue
            $count++
        }
    }
    
    Add-Change -Category "AppRemoval" -Action "Remove HP Bloatware ($count removed)" -Status "Success"
    if ($count -gt 0) { Write-Host " [OK] $count HP apps removed" -ForegroundColor Green }
    else { Write-Host " [-] No HP bloatware found" -ForegroundColor DarkGray }
}

function Restore-StoreApps {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Reinstalling Store apps..." -ForegroundColor Yellow
    
    Get-AppXPackage | ForEach-Object {
        if (Test-Path "$env:ProgramFiles\WindowsApps\$($_.PackageFullName)") {
            Add-AppxPackage -Register "$env:ProgramFiles\WindowsApps\$($_.PackageFullName)\AppxManifest.xml" -DisableDevelopmentMode -ErrorAction SilentlyContinue
        }
    }
    
    Add-Change -Category "AppRemoval" -Action "Reinstall Missing Store Apps" -Status "Success"
    Write-Host " [OK] Store apps reinstalled" -ForegroundColor Green
}

function Show-InstalledApps {
    Write-Host ""
    Write-Host " Installed Apps:" -ForegroundColor Cyan
    Write-Host "----------------" -ForegroundColor DarkGray
    Get-AppxPackage | Select-Object Name, PackageFullName | Format-Table -AutoSize -Wrap
    Write-Host ""
    Read-Host " Press Enter to continue"
}

# ====== CUSTOMIZATION TWEAKS ======

function Enable-DarkMode {
    Write-Host " [+] Enabling Dark Mode..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Enable Dark Mode" -Status "Success"
    Write-Host " [OK] Dark Mode enabled" -ForegroundColor Green
}

function Taskbar-AlignLeft {
    Write-Host " [+] Aligning taskbar to left..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Taskbar Align Left" -Status "Success"
    Write-Host " [OK] Taskbar aligned left" -ForegroundColor Green
}

function Taskbar-HideItems {
    Write-Host " [+] Hiding taskbar clutter..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Taskbar: Hide Search, Widgets, Chat" -Status "Success"
    Write-Host " [OK] Taskbar clutter hidden" -ForegroundColor Green
}

function Taskbar-NeverCombine {
    Write-Host " [+] Setting taskbar to never combine..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Taskbar: Never Combine" -Status "Success"
    Write-Host " [OK] Taskbar never combine enabled" -ForegroundColor Green
}

function Taskbar-EndTask {
    Write-Host " [+] Enabling End Task option..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDeveloperSettings" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Taskbar: Enable End Task" -Status "Success"
    Write-Host " [OK] End Task enabled" -ForegroundColor Green
}

function StartMenu-RemoveRecommended {
    Write-Host " [+] Removing Recommended from Start..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "ShowRecentlyAddedApps" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_ShowRecommended" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Start Menu: Remove Recommended" -Status "Success"
    Write-Host " [OK] Recommended removed from Start" -ForegroundColor Green
}

function StartMenu-RemoveBing {
    Write-Host " [+] Removing Bing Search from Start..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Start Menu: Remove Bing Search" -Status "Success"
    Write-Host " [OK] Bing Search disabled" -ForegroundColor Green
}

function Explorer-ShowHidden {
    Write-Host " [+] Showing hidden files & extensions..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Explorer: Show Hidden Files & Extensions" -Status "Success"
    Write-Host " [OK] Hidden files & extensions shown" -ForegroundColor Green
}

function Explorer-OldContextMenu {
    Write-Host " [+] Restoring old context menu..." -ForegroundColor Yellow
    
    New-Item -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(default)" -Type String -Value "" -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "Explorer: Old Context Menu" -Status "Success"
    Write-Host " [OK] Old context menu restored" -ForegroundColor Green
}

function Explorer-HideGallery {
    Write-Host " [+] Hiding Gallery & Home from Explorer..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDesktop\DefView\MSLocal" -Name "ShowHome" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Customize" -Action "File Explorer: Hide Gallery & Home" -Status "Success"
    Write-Host " [OK] Gallery & Home hidden" -ForegroundColor Green
}

function Apply-AllCustomization {
    Enable-DarkMode
    Taskbar-AlignLeft
    Taskbar-HideItems
    Taskbar-NeverCombine
    Taskbar-EndTask
    StartMenu-RemoveRecommended
    StartMenu-RemoveBing
    Explorer-ShowHidden
    Explorer-OldContextMenu
    Explorer-HideGallery
    Write-Host ""
    Write-Host " [DONE] All Customization tweaks applied!" -ForegroundColor Green
}

# ====== WINDOWS UPDATE TWEAKS ======

function Disable-AutoUpdates {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Automatic Updates..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name "AUOptions" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Set-Service -Name wuauserv -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Updates" -Action "Disable Automatic Updates" -Status "Success"
    Write-Host " [OK] Automatic Updates disabled" -ForegroundColor Green
}

function Disable-UpdateASAP {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Update ASAP..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "UpdateNotificationLevel" -Type DWord -Value 2 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "BranchReadinessLevel" -Type DWord -Value 20 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -Type DWord -Value 20 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "AllowMUUpdateService" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Updates" -Action "Disable Update ASAP (Preview)" -Status "Success"
    Write-Host " [OK] Update ASAP disabled" -ForegroundColor Green
}

function Prevent-AutoReboot {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Preventing automatic reboot..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\UX\Settings" -Name "RestartNotificationsAllowed2" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\UX\Settings" -Name "IsActiveHoursEnabled" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Updates" -Action "Prevent Automatic Reboot" -Status "Success"
    Write-Host " [OK] Auto reboot prevented" -ForegroundColor Green
}

function Disable-DeliveryOpt {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Delivery Optimization..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Updates" -Action "Disable Delivery Optimization" -Status "Success"
    Write-Host " [OK] Delivery Optimization disabled" -ForegroundColor Green
}

function Disable-FastStartup {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Fast Startup..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    powercfg /h off 2>$null
    
    Add-Change -Category "Updates" -Action "Disable Fast Startup" -Status "Success"
    Write-Host " [OK] Fast Startup disabled" -ForegroundColor Green
}

function Disable-BitlockerAuto {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling BitLocker Auto-Encryption..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\BitLocker" -Name "RequireDeviceEncryption" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\BitLocker" -Name "PreventDeviceEncryption" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\BitLocker" -Name "DeviceEncryption" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Set-Service -Name BDESVC -StartupType Disabled -ErrorAction SilentlyContinue
    
    Add-Change -Category "Updates" -Action "Disable BitLocker Auto-Encryption" -Status "Success"
    Write-Host " [OK] BitLocker Auto-Encryption disabled" -ForegroundColor Green
}

function Disable-ModernStandby {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Modern Standby Network..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Power" -Name "AllowNetworkDuringStandby" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-ea664401d457" -Name "DCSettingIndex" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-ea664401d457" -Name "ACSettingIndex" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Updates" -Action "Disable Modern Standby Network" -Status "Success"
    Write-Host " [OK] Modern Standby Network disabled" -ForegroundColor Green
}

function Disable-StorageSense {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling Storage Sense..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "04" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "08" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "32" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Updates" -Action "Disable Storage Sense" -Status "Success"
    Write-Host " [OK] Storage Sense disabled" -ForegroundColor Green
}

function Apply-AllUpdate {
    Disable-AutoUpdates
    Disable-UpdateASAP
    Prevent-AutoReboot
    Disable-DeliveryOpt
    Disable-FastStartup
    Disable-BitlockerAuto
    Disable-ModernStandby
    Disable-StorageSense
    Write-Host ""
    Write-Host " [DONE] All Update tweaks applied!" -ForegroundColor Green
}

# ====== NETWORK & DNS ======

function Set-DNS {
    param([string]$Name, [string]$Primary, [string]$Secondary)
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Changing DNS to $Name..." -ForegroundColor Yellow
    
    $adapters = Get-NetAdapter | Where-Object Status -eq "Up"
    foreach ($adapter in $adapters) {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.InterfaceIndex -ServerAddresses ($Primary, $Secondary) -ErrorAction SilentlyContinue
        Write-Host "    - $($adapter.Name): $Primary, $Secondary" -ForegroundColor Gray
    }
    
    Add-Change -Category "Network" -Action "Change DNS to $Name ($Primary)" -Status "Success"
    Write-Host " [OK] DNS changed to $Name" -ForegroundColor Green
}

function Flush-DNS {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Flushing DNS cache..." -ForegroundColor Yellow
    
    ipconfig /flushdns 2>$null
    ipconfig /registerdns 2>$null
    
    Add-Change -Category "Network" -Action "Flush DNS Cache" -Status "Success"
    Write-Host " [OK] DNS cache flushed" -ForegroundColor Green
}

function Disable-IPv6 {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Disabling IPv6..." -ForegroundColor Yellow
    
    $adapters = Get-NetAdapter | Where-Object Status -eq "Up"
    foreach ($adapter in $adapters) {
        Disable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue
    }
    
    Add-Change -Category "Network" -Action "Disable IPv6" -Status "Success"
    Write-Host " [OK] IPv6 disabled" -ForegroundColor Green
}

function Reset-Network {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Resetting network stack..." -ForegroundColor Yellow
    
    netsh int ip reset 2>$null
    netsh winsock reset 2>$null
    ipconfig /release 2>$null
    ipconfig /renew 2>$null
    ipconfig /flushdns 2>$null
    
    Add-Change -Category "Network" -Action "Reset Network Stack" -Status "Success"
    Write-Host " [OK] Network stack reset" -ForegroundColor Green
}

# ====== ADVANCED TOOLS ======

function System-Cleanup {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Running system cleanup..." -ForegroundColor Yellow
    
    $tempFolders = @(
        "$env:TEMP",
        "$env:WINDIR\Temp",
        "$env:WINDIR\Prefetch",
        "$env:LOCALAPPDATA\Temp"
    )
    
    foreach ($f in $tempFolders) {
        if (Test-Path $f) {
            $items = Get-ChildItem -Path $f -Recurse -Force -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                try { 
                    Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                } catch {}
            }
        }
    }
    
    cleanmgr /sagerun:1 2>$null
    
    Add-Change -Category "Advanced" -Action "System Cleanup" -Status "Success"
    Write-Host " [OK] System cleanup completed" -ForegroundColor Green
}

function Registry-Fixes {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Applying registry fixes..." -ForegroundColor Yellow
    
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters" -Name "TCPNoDelay" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Force -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpAckFrequency" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "TCPNoDelay" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" -Name "ShippedWithReserves" -Type DWord -Value 0 -Force -ErrorAction SilentlyContinue
    
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Advanced" -Action "Registry Fixes Applied" -Status "Success"
    Write-Host " [OK] Registry fixes applied" -ForegroundColor Green
}

function Block-Trackers {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Blocking trackers via HOSTS file..." -ForegroundColor Yellow
    
    $hostsPath = "$env:SYSTEMROOT\System32\drivers\etc\hosts"
    $backupPath = "$hostsPath.backup"
    
    Copy-Item -Path $hostsPath -Destination $backupPath -Force -ErrorAction SilentlyContinue
    
    $trackers = @(
        "0.0.0.0 doubleclick.net"
        "0.0.0.0 googleadservices.com"
        "0.0.0.0 googleads.g.doubleclick.net"
        "0.0.0.0 googlesyndication.com"
        "0.0.0.0 google-analytics.com"
        "0.0.0.0 googletagmanager.com"
        "0.0.0.0 connect.facebook.net"
        "0.0.0.0 pixel.facebook.com"
        "0.0.0.0 an.facebook.com"
        "0.0.0.0 at.atgs.com"
        "0.0.0.0 bs.serving-sys.com"
        "0.0.0.0 ad.doubleclick.net"
        "0.0.0.0 adservice.google.com"
        "0.0.0.0 pagead2.googlesyndication.com"
        "0.0.0.0 partner.googleadservices.com"
        "0.0.0.0 tpc.googlesyndication.com"
        "0.0.0.0 pixel.quantserve.com"
        "0.0.0.0 secure.quantserve.com"
        "0.0.0.0 sc.omtrdc.net"
        "0.0.0.0 stats.g.doubleclick.net"
        "0.0.0.0 adserver.adtechus.com"
        "0.0.0.0 adserver.adtech.de"
        "0.0.0.0 ib.adnxs.com"
        "0.0.0.0 ads.pubmatic.com"
        "0.0.0.0 adsrvr.org"
        "0.0.0.0 rlcdn.com"
        "0.0.0.0 bidder.criteo.com"
        "0.0.0.0 cas.criteo.com"
        "0.0.0.0 dis.criteo.com"
        "0.0.0.0 ads.stickyadstv.com"
        "0.0.0.0 adnxs.com"
        "0.0.0.0 dt.adsafeprotected.com"
        "0.0.0.0 adsafeprotected.com"
        "0.0.0.0 moatads.com"
        "0.0.0.0 js.moatads.com"
        "0.0.0.0 geo.moatads.com"
        "0.0.0.0 secure.adnxs.com"
        "0.0.0.0 ads.yahoo.com"
        "0.0.0.0 analytics.twitter.com"
        "0.0.0.0 telemetry.microsoft.com"
        "0.0.0.0 watson.telemetry.microsoft.com"
        "0.0.0.0 vortex.data.microsoft.com"
        "0.0.0.0 settings-win.data.microsoft.com"
    )
    
    $currentContent = Get-Content $hostsPath -Raw
    $added = 0
    foreach ($entry in $trackers) {
        if ($currentContent -notmatch [regex]::Escape($entry)) {
            Add-Content -Path $hostsPath -Value $entry -Encoding UTF8
            $added++
        }
    }
    
    Add-Change -Category "Advanced" -Action "Block Trackers via HOSTS ($added added)" -Status "Success"
    Write-Host " [OK] $added trackers blocked in HOSTS file" -ForegroundColor Green
}

function Show-SystemInfo {
    Write-Host ""
    Write-Host "  SYSTEM INFORMATION" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor DarkGray
    
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ram = Get-CimInstance Win32_ComputerSystem
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    $gpu = Get-CimInstance Win32_VideoController | Select-Object -First 1
    
    Write-Host " OS:          $($os.Caption)" -ForegroundColor White
    Write-Host " Version:     $($os.Version)" -ForegroundColor White
    Write-Host " Build:       $($os.BuildNumber)" -ForegroundColor White
    Write-Host " CPU:         $($cpu.Name)" -ForegroundColor White
    Write-Host " Cores:       $($cpu.NumberOfCores)" -ForegroundColor White
    Write-Host " RAM:         $([math]::Round($ram.TotalPhysicalMemory/1GB, 2)) GB" -ForegroundColor White
    Write-Host " GPU:         $($gpu.Name)" -ForegroundColor White
    
    foreach ($d in $disk) {
        $free = [math]::Round($d.FreeSpace/1GB, 2)
        $total = [math]::Round($d.Size/1GB, 2)
        Write-Host " Disk $($d.DeviceID):   $free GB free / $total GB total" -ForegroundColor White
    }
    
    Write-Host ""
    Read-Host " Press Enter to continue"
}

function Create-RestorePoint {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Creating System Restore Point..." -ForegroundColor Yellow
    
    Enable-ComputerRestore -Drive "$env:SYSTEMDRIVE" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "0xlaMo Tweaks - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -RestorePointType MODIFY_SETTINGS -ErrorAction SilentlyContinue
    
    Add-Change -Category "Advanced" -Action "Create System Restore Point" -Status "Success"
    Write-Host " [OK] Restore point created" -ForegroundColor Green
}

function Toggle-UAC {
    if (-not (Require-Admin)) { return }
    Write-Host ""
    Write-Host "  [1] Enable UAC (Recommended)" -ForegroundColor White
    Write-Host "  [2] Disable UAC" -ForegroundColor White
    Write-Host "  [B] Back" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host " Choose option"
    switch ($choice) {
        '1' {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Type DWord -Value 1 -Force
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 2 -Force
            Add-Change -Category "Advanced" -Action "Enable UAC" -Status "Success"
            Write-Host " [OK] UAC enabled" -ForegroundColor Green
        }
        '2' {
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Type DWord -Value 0 -Force
            Add-Change -Category "Advanced" -Action "Disable UAC" -Status "Success"
            Write-Host " [OK] UAC disabled" -ForegroundColor Green
        }
    }
}

function Enable-UTCTime {
    if (-not (Require-Admin)) { return }
    Write-Host " [+] Enabling UTC Time (for dual boot)..." -ForegroundColor Yellow
    
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1 -Force
    
    Add-Change -Category "Advanced" -Action "Enable UTC Time (Dual Boot)" -Status "Success"
    Write-Host " [OK] UTC time enabled" -ForegroundColor Green
}

function Disable-Defender {
    if (-not (Require-Admin)) { return }
    Write-Host " [!] Disabling Windows Defender requires Safe Mode!" -ForegroundColor Red
    Write-Host " [!] This tweak may reduce system security." -ForegroundColor Yellow
    Write-Host ""
    
    $choice = Read-Host " Are you sure? (y/n)"
    if ($choice -notmatch '^[Yy]$') { Write-Host " Skipped." -ForegroundColor DarkGray; return }
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableIOAVProtection" -Type DWord -Value 1 -Force -ErrorAction SilentlyContinue
    
    Add-Change -Category "Advanced" -Action "Disable Windows Defender" -Status "Success"
    Write-Host " [OK] Windows Defender disabled" -ForegroundColor Green
}

function Apply-AllRecommended {
    Write-Host ""
    Write-Host " ====== APPLYING ALL RECOMMENDED TWEAKS ======" -ForegroundColor Cyan
    Write-Host ""
    
    if (-not (Require-Admin)) { return }
    
    Disable-Telemetry
    Disable-Cortana
    Disable-CopilotAI
    Disable-AdsSuggestions
    Disable-Services
    Enable-GamingOptimizations
    Set-PowerSettings
    Disable-Animations
    Disable-StickyKeys
    Remove-Bloatware
    Enable-DarkMode
    Taskbar-HideItems
    StartMenu-RemoveRecommended
    Explorer-ShowHidden
    Disable-DeliveryOpt
    Disable-FastStartup
    Disable-StorageSense
    Flush-DNS
    Registry-Fixes
    
    Write-Host ""
    Write-Host " ====== ALL RECOMMENDED TWEAKS APPLIED! ======" -ForegroundColor Green
}

# ====== SUB-MENU HANDLERS ======

function Handle-PrivacyMenu {
    do {
        Show-PrivacyMenu
        $choice = Read-Host " Select option"
        switch ($choice) {
            '1' { Disable-Telemetry }
            '2' { Disable-Cortana }
            '3' { Disable-CopilotAI }
            '4' { Disable-ActivityHistory }
            '5' { Disable-LocationServices }
            '6' { Disable-AdsSuggestions }
            '7' { Disable-OfficeTelemetry }
            '8' { Disable-StoreSuggestions }
            '9' { Apply-AllPrivacy }
            'b' { return }
            'B' { return }
        }
        if ($choice -match '^[1-9]$') {
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
    } while ($true)
}

function Handle-PerformanceMenu {
    do {
        Show-PerformanceMenu
        $choice = Read-Host " Select option"
        switch ($choice) {
            '1' { Disable-Services }
            '2' { Enable-GamingOptimizations }
            '3' { Disable-HPET }
            '4' { Set-PowerSettings }
            '5' { Disable-Startups }
            '6' { Disable-Animations }
            '7' { Disable-MouseAcceleration }
            '8' { Disable-StickyKeys }
            '9' { Apply-AllPerformance }
            'b' { return }
            'B' { return }
        }
        if ($choice -match '^[1-9]$') {
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
    } while ($true)
}

function Handle-AppRemovalMenu {
    do {
        Show-AppRemovalMenu
        $choice = Read-Host " Select option"
        switch ($choice) {
            '1' { Remove-Bloatware }
            '2' { Remove-XboxApps }
            '3' { Remove-OneDrive }
            '4' { Remove-Edge }
            '5' { Remove-AllUWP }
            '6' { Remove-HPBloat }
            '7' { Restore-StoreApps }
            '8' { Show-InstalledApps }
            'b' { return }
            'B' { return }
        }
        if ($choice -match '^[1-7]$') {
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
    } while ($true)
}

function Handle-CustomizeMenu {
    do {
        Show-CustomizeMenu
        $choice = Read-Host " Select option"
        switch ($choice) {
            '1' { Enable-DarkMode }
            '2' { Taskbar-AlignLeft }
            '3' { Taskbar-HideItems }
            '4' { Taskbar-NeverCombine }
            '5' { Taskbar-EndTask }
            '6' { StartMenu-RemoveRecommended }
            '7' { StartMenu-RemoveBing }
            '8' { Explorer-ShowHidden }
            '9' { Explorer-OldContextMenu }
            '10' { Explorer-HideGallery }
            '11' { Apply-AllCustomization }
            'b' { return }
            'B' { return }
        }
        if ($choice -match '^[1-9]$|^10$|^11$') {
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
    } while ($true)
}

function Handle-UpdateMenu {
    do {
        Show-UpdateMenu
        $choice = Read-Host " Select option"
        switch ($choice) {
            '1' { Disable-AutoUpdates }
            '2' { Disable-UpdateASAP }
            '3' { Prevent-AutoReboot }
            '4' { Disable-DeliveryOpt }
            '5' { Disable-FastStartup }
            '6' { Disable-BitlockerAuto }
            '7' { Disable-ModernStandby }
            '8' { Disable-StorageSense }
            '9' { Apply-AllUpdate }
            'b' { return }
            'B' { return }
        }
        if ($choice -match '^[1-9]$') {
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
    } while ($true)
}

function Handle-NetworkMenu {
    do {
        Show-NetworkMenu
        $choice = Read-Host " Select option"
        switch ($choice) {
            '1' { Set-DNS -Name "Cloudflare" -Primary "1.1.1.1" -Secondary "1.0.0.1" }
            '2' { Set-DNS -Name "Google" -Primary "8.8.8.8" -Secondary "8.8.4.4" }
            '3' { Set-DNS -Name "OpenDNS" -Primary "208.67.222.222" -Secondary "208.67.220.220" }
            '4' { Set-DNS -Name "Quad9" -Primary "9.9.9.9" -Secondary "149.112.112.112" }
            '5' { Flush-DNS }
            '6' { Disable-IPv6 }
            '7' { Reset-Network }
            'b' { return }
            'B' { return }
        }
        if ($choice -match '^[1-7]$') {
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
    } while ($true)
}

function Handle-AdvancedMenu {
    do {
        Show-AdvancedMenu
        $choice = Read-Host " Select option"
        switch ($choice) {
            '1' { System-Cleanup }
            '2' { Registry-Fixes }
            '3' { Block-Trackers }
            '4' { Show-SystemInfo }
            '5' { Create-RestorePoint }
            '6' { Toggle-UAC }
            '7' { Enable-UTCTime }
            '8' { Disable-Defender }
            'b' { return }
            'B' { return }
        }
        if ($choice -match '^[1-8]$') {
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
    } while ($true)
}

# ====== MAIN ======

Show-Splash

Write-Host " [!] Some tweaks require Administrator privileges" -ForegroundColor Yellow
Write-Host " [!] Please run as Administrator for full functionality" -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Milliseconds 500

do {
    Show-MainMenu
    $choice = Read-Host " Select option"
    switch ($choice) {
        '1' { Handle-PrivacyMenu }
        '2' { Handle-PerformanceMenu }
        '3' { Handle-AppRemovalMenu }
        '4' { Handle-CustomizeMenu }
        '5' { Handle-UpdateMenu }
        '6' { Handle-NetworkMenu }
        '7' { Handle-AdvancedMenu }
        '8' { Apply-AllRecommended }
        '9' {
            Clear-Host
            Write-Host ""
            Write-Host " ====== SUMMARY ======" -ForegroundColor Cyan
            Write-Host ""
            if ($script:Changes.Count -eq 0) {
                Write-Host " No changes made yet." -ForegroundColor DarkGray
            } else {
                $grouped = $script:Changes | Group-Object Category
                foreach ($g in $grouped) {
                    Write-Host " [$($g.Name)] ($($g.Count) changes)" -ForegroundColor Yellow
                    foreach ($c in $g.Group) {
                        $sym = if ($c.Status -eq "Success") { "[OK]" } else { "[X]" }
                        Write-Host "   $sym $($c.Action)" -ForegroundColor Gray
                    }
                }
            }
            Write-Host ""
            $save = Read-Host " Save report to Desktop? (y/n)"
            if ($save -match '^[Yy]$') {
                Save-Results
            }
            Write-Host ""
            Read-Host " Press Enter to continue"
        }
        '0' {
            Write-Host ""
            if ($script:Changes.Count -gt 0) {
                $save = Read-Host " Save report before exiting? (y/n)"
                if ($save -match '^[Yy]$') {
                    Save-Results
                }
            }
            Write-Host ""
            Write-Host " Goodbye! - Made by " -NoNewline
            Write-Host "0xlamo" -ForegroundColor Cyan
            Write-Host ""
            exit
        }
    }
} while ($true)
