Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("User32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) | Out-Null

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$soundUrl = "https://raw.githubusercontent.com/sodafilledcans/funnypowershellstuff/main/ScarySound.mp3"
$soundPath = "$env:TEMP\scary_sound.mp3"

try {
    Invoke-WebRequest -Uri $soundUrl -OutFile $soundPath -ErrorAction Stop
    Start-Process $soundPath
} catch {}

$form = New-Object System.Windows.Forms.Form
$form.Text = "SodaGrabber v2.0 - SYSTEM ACCESS"
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.BackColor = "Black"
$form.KeyPreview = $true
$form.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") {
        $form.Close()
        [System.Windows.Forms.Application]::Exit()
    }
})

$label = New-Object System.Windows.Forms.Label
$label.ForeColor = "Lime"
$label.BackColor = "Black"
$label.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$label.Text = ""
$label.AutoSize = $false
$label.Size = New-Object System.Drawing.Size($form.Width, $form.Height)
$label.TextAlign = "TopLeft"
$label.Padding = New-Object System.Windows.Forms.Padding(20, 20, 20, 20)

$form.Controls.Add($label)
$form.Show()
$form.Refresh()
Start-Sleep -Milliseconds 1350

$username = [Environment]::UserName

$displayText = "Hello $username!`r`n`r`nInitializing SodaGrabber v2.0...`r`n"
$label.Text = $displayText
$form.Refresh()
Start-Sleep -Seconds 2
$displayText += "Scanning system directories...`r`n`r`n"
$label.Text = $displayText
$form.Refresh()
Start-Sleep -Seconds 1

$scanLocations = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Music",
    "C:\Program Files",
    "C:\Program Files (x86)",
    "$env:USERPROFILE\AppData\Local",
    "$env:USERPROFILE\AppData\Roaming",
    "C:\Windows\System32",
    "C:\Windows"
)

$foundFiles = @()
$scanStartTime = Get-Date
$scanDuration = 101
$scanEndTime = $scanStartTime.AddSeconds($scanDuration)

$allFiles = @()
foreach ($location in $scanLocations) {
    if (Test-Path $location) {
        try {
            $files = Get-ChildItem -Path $location -File -ErrorAction SilentlyContinue -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -First 200
            $allFiles += $files
        } catch {}
    }
}

$allFiles = $allFiles | Where-Object { $_.Name -ne $null } | Sort-Object { Get-Random }

if ($allFiles.Count -eq 0) {
    for ($i = 1; $i -le 1000; $i++) {
        $allFiles += [PSCustomObject]@{
            Name = "system_file_$i.dll"
            FullName = "C:\Windows\System32\system_file_$i.dll"
            Length = Get-Random -Minimum 1000 -Maximum 10000000
        }
    }
}

$fileIndex = 0
$totalFiles = $allFiles.Count
$lastCleanup = Get-Date

while ((Get-Date) -lt $scanEndTime) {
    $currentFile = $allFiles[$fileIndex % $totalFiles]
    $fileIndex++
    
    $fileName = $currentFile.Name
    $fileSize = [math]::Round($currentFile.Length / 1MB, 2)
    if ($fileSize -lt 0.01) { $fileSize = Get-Random -Minimum 0.1 -Maximum 50 }
    
    $filePath = $currentFile.FullName
    if (-not $filePath) { $filePath = "C:\Unknown\Path\$fileName" }
    
    $foundFiles += $fileName
    
    $displayText += "[FOUND] $fileName`r`n"
    $displayText += "[LOCATION] $filePath`r`n"
    $displayText += "[SIZE] $fileSize MB`r`n"
    $displayText += "[DOWNLOADING] $fileName...`r`n"
    
    $elapsed = ((Get-Date) - $scanStartTime).TotalSeconds
    $percentComplete = [math]::Round(($elapsed / $scanDuration) * 100)
    $displayText += "[PROGRESS] $percentComplete% - $fileIndex files found`r`n`r`n"
    
    if ((Get-Date) - $lastCleanup -gt [TimeSpan]::FromSeconds(3)) {
        $lines = $displayText -split "`r`n"
        if ($lines.Count -gt 40) {
            $displayText = ($lines[-40..-1] -join "`r`n")
        }
        $lastCleanup = Get-Date
    }
    
    $label.Text = $displayText
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
    
    $delay = Get-Random -Minimum 300 -Maximum 600
    Start-Sleep -Milliseconds $delay
}

$displayText += "`r`n" + "="*60 + "`r`n"
$displayText += "[SCAN COMPLETE] $($foundFiles | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count) unique files located`r`n"
$displayText += "[TRANSFER INITIATED] Connecting to SodaGrabber.xyz...`r`n"
$label.Text = $displayText
$form.Refresh()
Start-Sleep -Seconds 3

$foundFiles = $foundFiles | Select-Object -Unique

foreach ($file in $foundFiles) {
    $displayText += "`r`n[UPLOADING] $file -> SodaGrabber.xyz`r`n"
    $displayText += "[STATUS] .."
    $label.Text = $displayText
    $form.Refresh()
    Start-Sleep -Milliseconds 700
    $displayText += " ."
    $label.Text = $displayText
    $form.Refresh()
    Start-Sleep -Milliseconds 700
    $displayText += " .`r`n"
    $label.Text = $displayText
    $form.Refresh()
    Start-Sleep -Milliseconds 700
    $displayText += "[COMPLETED] $file transferred successfully!`r`n"
    $label.Text = $displayText
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

$displayText += "`r`n" + "!"*70 + "`r`n"
$displayText += "!!! UNAUTHORIZED TRANSFER DETECTED !!!`r`n"
$displayText += "!"*70 + "`r`n"
$label.Text = $displayText
$form.Refresh()
Start-Sleep -Seconds 2

foreach ($file in $foundFiles) {
    $displayText += "`r`n[ALERT] $file has been Transferred!`r`n"
    $displayText += "[WARNING] Remote server: 198.51.100.$((Get-Random -Minimum 1 -Maximum 255))`r`n"
    $displayText += "[STATUS] Data exfiltrated!`r`n"
    $label.Text = $displayText
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

Start-Sleep -Seconds 2

$displayText += "`r`n" + "█"*70 + "`r`n"
$displayText += "██ UHHH U R CRASHING REAL!! ██`r`n"
$displayText += "█"*70 + "`r`n"
$label.Text = $displayText
$form.Refresh()

$spamEnd = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $spamEnd) {
    $displayText += "[CRITICAL] SYSTEM DESTABILIZATION DETECTED - FORCING DESKTOP REDIRECT`r`n"
    $displayText += "[ERROR 0x$("{0:X4}" -f (Get-Random -Maximum 65535))] MEMORY CORRUPTION IN SECTOR $(Get-Random -Minimum 1 -Maximum 999)`r`n"
    $displayText += "[WARNING] $username.exe has stopped responding`r`n"
    $displayText += "[FATAL] Attempting to delete user profile...`r`n"
    $label.Text = $displayText
    $form.Refresh()
    
    Start-Sleep -Milliseconds 80
    [System.Windows.Forms.Application]::DoEvents()
}

$displayText += "`r`n`r`n" + " "*30 + "SYSTEM TERMINATION IN PROGRESS...`r`n"
$displayText += " "*30 + "Goodbye, $username!`r`n"
$label.Text = $displayText
$form.Refresh()
Start-Sleep -Seconds 3

$form.Close()
[System.Windows.Forms.Application]::Exit()

Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" } | Stop-Process -Force
if (Test-Path $soundPath) {
    Remove-Item $soundPath -Force -ErrorAction SilentlyContinue
}
