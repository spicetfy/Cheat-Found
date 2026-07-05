param(
  [switch]$Silent
)

$output = @"
╔══════════════════════════════════════════╗
║         Anti-Cheat Scanner Report         ║
╚══════════════════════════════════════════╝
التاريخ: $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
اسم الجهاز: $env:COMPUTERNAME
المستخدم: $env:USERNAME

"@

$cheatKeywords = @(
  'cheat', 'hack', 'modmenu', 'inject', 'wallhack', 'aimbot',
  'esp', 'spoofer', 'injector', 'bypass', 'dumper', 'hook',
  'memory', 'offset', 'driver', 'external', 'internal',
  'loader', 'crack', 'xenos', 'extreme', 'crosshair',
  'triggerbot', 'bhop', 'noflash', 'norecoil', 'speedhack',
  'flyhack', 'silentaim', 'radar', 'maphack', 'fovchanger'
)

$cheatProcesses = @(
  'cheatengine', 'cheatengine-x86_64', 'CEGUI', 'CheatEngine',
  'xenos', 'extremeinjector', 'processhacker', 'ollydbg',
  'x64dbg', 'x32dbg', 'reclass', 'ida', 'idapro', 'ida64',
  'httpproxy', 'fiddler', 'charles', 'wireshark', 'httpanalyzer',
  'dnspy', 'dotpeek', 'ildasm', 'de4dot', 'confuser',
  'obs64', 'obs32', 'streamlabs', 'autoit3', 'autohotkey',
  'pixelbot', 'colorpick', 'keylogger', 'macro_recorder',
  'windbg', 'immunity', 'gdb', 'python', 'perl', 'titanhide',
  'vmware', 'vbox', 'virtualbox', 'vmnat', 'vmusr',
  'sandboxie', 'sbie', 'privacy_eraser',
  'ac_client', 'ac_server', 'assaultcube'
)

$suspiciousUsernames = @(
  'cheat', 'hack', 'crack', 'modz', 'hvh', 'legit',
  'inject', 'bypass', 'spoof', 'rage', 'toggle',
  'priv8', 'private', 'unknowncheat', 'uc-forum'
)

$suspiciousPaths = @(
  "$env:TEMP",
  "$env:APPDATA",
  "$env:LOCALAPPDATA",
  "$env:USERPROFILE\Documents",
  "$env:USERPROFILE\Downloads",
  "$env:USERPROFILE\Desktop"
)

if (-not $Silent) {
  Write-Host "جارٍ فحص النظام..." -ForegroundColor Cyan
}

# ── 1. العمليات المشبوهة ──
$output += "`n[1] العمليات الجارية (Running Processes)`n"
$output += "────────────────────────────────`n"
$foundProcs = Get-Process | Where-Object {
  $n = $_.ProcessName.ToLower()
  $cheatProcesses -contains $n -or ($cheatKeywords | Where-Object { $n -match $_ })
}
if ($foundProcs) {
  $foundProcs | ForEach-Object { $output += "⚠ $($_.ProcessName) (PID: $($_.Id))`n" }
} else {
  $output += "✓ لا توجد عمليات مشبوهة`n"
}

# ── 2. ملفات مشبوهة في المجلدات الشائعة ──
$output += "`n[2] ملفات مشبوهة (Suspicious Files)`n"
$output += "────────────────────────────────`n"
$foundFiles = @()
foreach ($dir in $suspiciousPaths) {
  if (Test-Path $dir) {
    $results = Get-ChildItem -Path $dir -Recurse -Force -ErrorAction SilentlyContinue -File | Where-Object {
      $_.Name -match ($cheatKeywords -join '|') -and $_.Length -le 50MB
    }
    $foundFiles += $results
  }
}
if ($foundFiles) {
  $foundFiles | Group-Object DirectoryName | ForEach-Object {
    $output += "📁 $($_.Name)`n"
    $_.Group | ForEach-Object { $output += "   $($_.Name) ($([math]::Round($_.Length/1KB,1)) KB)`n" }
  }
} else {
  $output += "✓ لا توجد ملفات مشبوهة`n"
}

# ── 3. خدمات مشبوهة ──
$output += "`n[3] خدمات مشبوهة (Suspicious Services)`n"
$output += "────────────────────────────────`n"
$foundSvcs = Get-Service -ErrorAction SilentlyContinue | Where-Object {
  $n = $_.Name.ToLower()
  $cheatKeywords | Where-Object { $n -match $_ }
} | Select-Object Name, Status, StartType
if ($foundSvcs) {
  $foundSvcs | ForEach-Object { $output += "⚠ $($_.Name) — $($_.Status)`n" }
} else {
  $output += "✓ لا توجد خدمات مشبوهة`n"
}

# ── 4. درايفرات مشبوهة ──
$output += "`n[4] درايفرات محملة (Loaded Drivers)`n"
$output += "────────────────────────────────`n"
$foundDrivers = Get-WmiObject Win32_SystemDriver -ErrorAction SilentlyContinue | Where-Object {
  $n = $_.Name.ToLower()
  $cheatKeywords | Where-Object { $n -match $_ }
} | Select-Object Name, State, StartMode
if ($foundDrivers) {
  $foundDrivers | ForEach-Object { $output += "⚠ $($_.Name) — $($_.State)`n" }
} else {
  $output += "✓ لا توجد درايفرات مشبوهة`n"
}

# ── 5. مستخدمين مشبوهين ──
$output += "`n[5] حسابات ويندوز (User Accounts)`n"
$output += "────────────────────────────────`n"
$foundUsers = Get-LocalUser -ErrorAction SilentlyContinue | Where-Object {
  $n = $_.Name.ToLower()
  $suspiciousUsernames | Where-Object { $n -match $_ }
}
if ($foundUsers) {
  $foundUsers | ForEach-Object { $output += "⚠ مستخدم: $($_.Name)`n" }
} else {
  $output += "✓ لا توجد حسابات مشبوهة`n"
}

# ── 6. منافذ الشبكة المشبوهة ──
$output += "`n[6] اتصالات مشبوهة (Suspicious Connections)`n"
$output += "────────────────────────────────`n"
$netConns = Get-NetTCPConnection -ErrorAction SilentlyContinue | Where-Object {
  $_.RemotePort -eq 443 -or $_.RemotePort -eq 80 -or $_.RemotePort -eq 8080 -or $_.RemotePort -eq 8443
} | Select-Object -First 20
if ($netConns) {
  $netConns | ForEach-Object { $output += "🌐 $($_.RemoteAddress):$($_.RemotePort) — $($_.State)`n" }
} else {
  $output += "✓ لا توجد اتصالات لافتة`n"
}

# ── حفظ التقرير ──
$path = "$env:USERPROFILE\Desktop\CheatScan_$($env:COMPUTERNAME)_$((Get-Date).ToString('yyyyMMdd_HHmmss')).txt"
$output | Out-File -FilePath $path -Encoding UTF8

if (-not $Silent) {
  Write-Host "`n✅ التقرير محفوظ في:" -ForegroundColor Green
  Write-Host "   $path" -ForegroundColor Yellow
  Write-Host "`n⚠ يرجى إرسال الملف للمشرف." -ForegroundColor Cyan
}

return $path
