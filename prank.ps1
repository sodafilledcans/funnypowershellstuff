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

# Use RichTextBox instead of Label for unlimited scrolling
$textBox = New-Object System.Windows.Forms.RichTextBox
$textBox.ForeColor = "Lime"
$textBox.BackColor = "Black"
$textBox.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$textBox.Text = ""
$textBox.Dock = "Fill"
$textBox.ReadOnly = $true
$textBox.BorderStyle = "None"
$textBox.WordWrap = $true
$textBox.ScrollBars = "Vertical"

$form.Controls.Add($textBox)
$form.Show()
$form.Refresh()
Start-Sleep -Milliseconds 1350

$username = [Environment]::UserName

$textBox.Text = "Hello $username!`r`n`r`nInitializing SodaGrabber v2.0...`r`n"
$form.Refresh()
Start-Sleep -Seconds 2
$textBox.Text += "Scanning system directories...`r`n`r`n"
$form.Refresh()
Start-Sleep -Seconds 1

$scanLocations = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Music",
    "$env:USERPROFILE\AppData\Local",
    "$env:USERPROFILE\AppData\Roaming",
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\Windows\System32",
    "C:\Windows",
    "C:\"
)

$foundFiles = @()
$filePaths = @()
$scanStartTime = Get-Date
$scanDuration = 101
$scanEndTime = $scanStartTime.AddSeconds($scanDuration)

# Collect real files first
$allFiles = @()
foreach ($location in $scanLocations) {
    if (Test-Path $location) {
        try {
            Write-Host "Scanning $location..." -ForegroundColor Gray
            $files = Get-ChildItem -Path $location -File -ErrorAction SilentlyContinue -Recurse -Force -ErrorAction SilentlyContinue | 
                     Where-Object { $_.Length -gt 0 -and $_.Name -notlike "*System Volume Information*" } |
                     Select-Object -First 50
            $allFiles += $files
            Write-Host "Found $($files.Count) files in $location" -ForegroundColor Gray
        } catch {
            Write-Host "Error scanning $location : $_" -ForegroundColor Gray
        }
    } else {
        Write-Host "Location not found: $location" -ForegroundColor Gray
    }
}

$allFiles = $allFiles | Where-Object { $_.Name -ne $null } | Sort-Object { Get-Random }

Write-Host "Total real files collected: $($allFiles.Count)" -ForegroundColor Green

if ($allFiles.Count -eq 0) {
    Write-Host "No real files found, using fallback" -ForegroundColor Yellow
    for ($i = 1; $i -le 500; $i++) {
        $allFiles += [PSCustomObject]@{
            Name = "system_file_$i.dll"
            FullName = "C:\Windows\System32\system_file_$i.dll"
            Length = Get-Random -Minimum 1000 -Maximum 10000000
        }
    }
}

$fileIndex = 0
$totalFiles = $allFiles.Count
$lastScrollPos = 0

while ((Get-Date) -lt $scanEndTime) {
    $currentFile = $allFiles[$fileIndex % $totalFiles]
    $fileIndex++
    
    $fileName = $currentFile.Name
    $fileSize = [math]::Round($currentFile.Length / 1MB, 2)
    if ($fileSize -lt 0.01) { $fileSize = Get-Random -Minimum 0.1 -Maximum 5 }
    
    $filePath = $currentFile.FullName
    if (-not $filePath -or $filePath -eq "C:\Unknown\Path\$fileName") {
        # Try to find a real path for this file
        $realFile = Get-ChildItem -Path $env:USERPROFILE -File -Recurse -ErrorAction SilentlyContinue | 
                    Where-Object { $_.Name -eq $fileName } | 
                    Select-Object -First 1
        if ($realFile) {
            $filePath = $realFile.FullName
            $fileSize = [math]::Round($realFile.Length / 1MB, 2)
        }
    }
    
    $foundFiles += $fileName
    $filePaths += $filePath
    
    $textBox.Text += "[FOUND] $fileName`r`n"
    $textBox.Text += "[LOCATION] $filePath`r`n"
    $textBox.Text += "[SIZE] $fileSize MB`r`n"
    $textBox.Text += "[DOWNLOADING] $fileName...`r`n"
    
    $elapsed = ((Get-Date) - $scanStartTime).TotalSeconds
    $percentComplete = [math]::Round(($elapsed / $scanDuration) * 100)
    $textBox.Text += "[PROGRESS] $percentComplete% - $fileIndex files found`r`n`r`n"
    
    # Auto-scroll to bottom
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
    
    $delay = Get-Random -Minimum 200 -Maximum 400
    Start-Sleep -Milliseconds $delay
}

$textBox.Text += "`r`n" + "="*60 + "`r`n"
$textBox.Text += "[SCAN COMPLETE] $($foundFiles | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count) unique files located`r`n"
$textBox.Text += "[TRANSFER INITIATED] Connecting to SodaGrabber.xyz...`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$form.Refresh()
Start-Sleep -Seconds 3

$foundFiles = $foundFiles | Select-Object -Unique
$filePaths = $filePaths | Select-Object -Unique

for ($i = 0; $i -lt $foundFiles.Count; $i++) {
    $file = $foundFiles[$i]
    $path = if ($i -lt $filePaths.Count) { $filePaths[$i] } else { "C:\Unknown\Path\$file" }
    
    $textBox.Text += "`r`n[UPLOADING] $file -> SodaGrabber.xyz`r`n"
    $textBox.Text += "[FROM] $path`r`n"
    $textBox.Text += "[STATUS] .."
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    $textBox.Text += " ."
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    $textBox.Text += " .`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    $textBox.Text += "[COMPLETED] $file transferred successfully!`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

$textBox.Text += "`r`n" + "!"*70 + "`r`n"
$textBox.Text += "!!! UNAUTHORIZED TRANSFER DETECTED !!!`r`n"
$textBox.Text += "!"*70 + "`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$form.Refresh()
Start-Sleep -Seconds 2

for ($i = 0; $i -lt $foundFiles.Count; $i++) {
    $file = $foundFiles[$i]
    $textBox.Text += "`r`n[ALERT] $file has been Transferred!`r`n"
    $textBox.Text += "[WARNING] Remote server: 198.51.100.$((Get-Random -Minimum 1 -Maximum 255))`r`n"
    $textBox.Text += "[STATUS] Data exfiltrated!`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}

Start-Sleep -Seconds 2

$textBox.Text += "`r`n" + "█"*70 + "`r`n"
$textBox.Text += "██ UHHH U R CRASHING REAL!! ██`r`n"
$textBox.Text += "█"*70 + "`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$form.Refresh()

$spamEnd = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $spamEnd) {
    $textBox.Text += "[CRITICAL] SYSTEM DESTABILIZATION DETECTED - FORCING DESKTOP REDIRECT`r`n"
    $textBox.Text += "[ERROR 0x$("{0:X4}" -f (Get-Random -Maximum 65535))] MEMORY CORRUPTION IN SECTOR $(Get-Random -Minimum 1 -Maximum 999)`r`n"
    $textBox.Text += "[WARNING] $username.exe has stopped responding`r`n"
    $textBox.Text += "[FATAL] Attempting to delete user profile...`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $form.Refresh()
    
    Start-Sleep -Milliseconds 80
    [System.Windows.Forms.Application]::DoEvents()
}

$textBox.Text += "`r`n`r`n" + " "*30 + "SYSTEM TERMINATION IN PROGRESS...`r`n"
$textBox.Text += " "*30 + "Goodbye, $username!`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$form.Refresh()
Start-Sleep -Seconds 3

$form.Close()
[System.Windows.Forms.Application]::Exit()

Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" } | Stop-Process -Force
if (Test-Path $soundPath) {
    Remove-Item $soundPath -Force -ErrorAction SilentlyContinue
}
