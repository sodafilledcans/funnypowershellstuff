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

$textBox = New-Object System.Windows.Forms.RichTextBox
$textBox.ForeColor = "Lime"
$textBox.BackColor = "Black"
$textBox.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
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
if ($form.IsDisposed) { return }
$textBox.Text += "Scanning system directories...`r`n`r`n"
$form.Refresh()
Start-Sleep -Seconds 1
if ($form.IsDisposed) { return }

$scanLocations = @(
    "$env:USERPROFILE\Desktop",
    "$env:USERPROFILE\Documents",
    "$env:USERPROFILE\Downloads",
    "$env:USERPROFILE\Pictures",
    "$env:USERPROFILE\Videos",
    "$env:USERPROFILE\Music"
)

$foundFiles = @()
$scanStartTime = Get-Date
$scanDuration = 101
$scanEndTime = $scanStartTime.AddSeconds($scanDuration)

$allFiles = @()
foreach ($location in $scanLocations) {
    if ($form.IsDisposed) { return }
    if (Test-Path $location) {
        try {
            $files = Get-ChildItem -Path $location -File -ErrorAction SilentlyContinue | Select-Object -First 50
            $allFiles += $files
        } catch {}
    }
}

if ($form.IsDisposed) { return }

$allFiles = $allFiles | Where-Object { $_.Name -ne $null } | Sort-Object { Get-Random }
$totalFiles = $allFiles.Count

if ($totalFiles -eq 0) {
    $textBox.Text += "ERROR: No files found on system!`r`n"
    $textBox.Text += "Press ESC to exit`r`n"
    $form.Refresh()
    while (-not $form.IsDisposed) {
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }
    return
}

$fileIndex = 0

while ((Get-Date) -lt $scanEndTime -and -not $form.IsDisposed) {
    $currentFile = $allFiles[$fileIndex % $totalFiles]
    $fileIndex++
    
    $fileName = $currentFile.Name
    $fileSize = [math]::Round($currentFile.Length / 1MB, 2)
    $filePath = $currentFile.FullName
    
    $foundFiles += $fileName
    
    $textBox.Text += "[FOUND] $fileName`r`n"
    $textBox.Text += "[LOCATION] $filePath`r`n"
    $textBox.Text += "[SIZE] $fileSize MB`r`n"
    $textBox.Text += "[DOWNLOADING] $fileName...`r`n"
    
    $elapsed = ((Get-Date) - $scanStartTime).TotalSeconds
    $percentComplete = [math]::Round(($elapsed / $scanDuration) * 100)
    $textBox.Text += "[PROGRESS] $percentComplete% - $fileIndex files found`r`n`r`n"
    
    # Force scroll to bottom
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $textBox.Refresh()
    
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
    
    Start-Sleep -Milliseconds 300
}

if ($form.IsDisposed) { return }

$textBox.Text += "`r`n" + "="*60 + "`r`n"
$textBox.Text += "[SCAN COMPLETE] $($foundFiles | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count) unique files located`r`n"
$textBox.Text += "[TRANSFER INITIATED] Connecting to SodaGrabber.xyz...`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$textBox.Refresh()
$form.Refresh()
Start-Sleep -Seconds 3
if ($form.IsDisposed) { return }

$foundFiles = $foundFiles | Select-Object -Unique

foreach ($file in $foundFiles) {
    if ($form.IsDisposed) { return }
    $textBox.Text += "`r`n[UPLOADING] $file -> SodaGrabber.xyz`r`n"
    $textBox.Text += "[STATUS] .."
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $textBox.Refresh()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    
    if ($form.IsDisposed) { return }
    $textBox.Text += " ."
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $textBox.Refresh()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    
    if ($form.IsDisposed) { return }
    $textBox.Text += " .`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $textBox.Refresh()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    
    if ($form.IsDisposed) { return }
    $textBox.Text += "[COMPLETED] $file transferred successfully!`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $textBox.Refresh()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

if ($form.IsDisposed) { return }

$textBox.ForeColor = "Red"
$textBox.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$textBox.Text += "`r`n" + "!"*70 + "`r`n"
$textBox.Text += "!!! UNAUTHORIZED TRANSFER DETECTED !!!`r`n"
$textBox.Text += "!"*70 + "`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$textBox.Refresh()
$form.Refresh()
Start-Sleep -Seconds 2
if ($form.IsDisposed) { return }

foreach ($file in $foundFiles) {
    if ($form.IsDisposed) { return }
    $textBox.Text += "`r`n[ALERT] $file has been Transferred!`r`n"
    $textBox.Text += "[WARNING] Remote server: 198.51.100.$((Get-Random -Minimum 1 -Maximum 255))`r`n"
    $textBox.Text += "[STATUS] Data exfiltrated!`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $textBox.Refresh()
    $form.Refresh()
    [System.Windows.Forms.Application]::DoEvents()
}

if ($form.IsDisposed) { return }
Start-Sleep -Seconds 2
if ($form.IsDisposed) { return }

$textBox.Text += "`r`n" + "█"*70 + "`r`n"
$textBox.Text += "██ UHHH U R CRASHING REAL!! ██`r`n"
$textBox.Text += "█"*70 + "`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$textBox.Refresh()
$form.Refresh()

$spamEnd = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $spamEnd -and -not $form.IsDisposed) {
    $textBox.Text += "[CRITICAL] SYSTEM DESTABILIZATION DETECTED - FORCING DESKTOP REDIRECT`r`n"
    $textBox.Text += "[ERROR 0x$("{0:X4}" -f (Get-Random -Maximum 65535))] MEMORY CORRUPTION IN SECTOR $(Get-Random -Minimum 1 -Maximum 999)`r`n"
    $textBox.Text += "[WARNING] $username.exe has stopped responding`r`n"
    $textBox.Text += "[FATAL] Attempting to delete user profile...`r`n"
    $textBox.SelectionStart = $textBox.Text.Length
    $textBox.ScrollToCaret()
    $textBox.Refresh()
    $form.Refresh()
    
    Start-Sleep -Milliseconds 80
    [System.Windows.Forms.Application]::DoEvents()
}

if ($form.IsDisposed) { return }

$textBox.Text += "`r`n`r`n" + " "*30 + "SYSTEM TERMINATION IN PROGRESS...`r`n"
$textBox.Text += " "*30 + "Goodbye, $username!`r`n"
$textBox.SelectionStart = $textBox.Text.Length
$textBox.ScrollToCaret()
$textBox.Refresh()
$form.Refresh()
Start-Sleep -Seconds 3

$form.Close()
[System.Windows.Forms.Application]::Exit()

Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" } | Stop-Process -Force
if (Test-Path $soundPath) {
    Remove-Item $soundPath -Force -ErrorAction SilentlyContinue
}
