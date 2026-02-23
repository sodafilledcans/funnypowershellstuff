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

$listView = New-Object System.Windows.Forms.ListView
$listView.ForeColor = "Lime"
$listView.BackColor = "Black"
$listView.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
$listView.Dock = "Fill"
$listView.BorderStyle = "None"
$listView.View = "Details"
$listView.HeaderStyle = "None"
$listView.Scrollable = $true
$listView.FullRowSelect = $false
$listView.GridLines = $false
$listView.AllowColumnReorder = $false
$listView.AutoResizeColumns = "None"

$listView.Columns.Add("Output", $form.Width)

$form.Controls.Add($listView)
$form.Show()
$form.Refresh()
Start-Sleep -Milliseconds 1350

$username = [Environment]::UserName

function Add-Output {
    param([string]$text)
    if ($form.IsDisposed) { return }
    
    $lines = $text -split "`r`n"
    foreach ($line in $lines) {
        if ($line.Trim() -ne "") {
            $item = New-Object System.Windows.Forms.ListViewItem($line)
            $item.ForeColor = "Lime"
            $item.BackColor = "Black"
            $listView.Items.Add($item)
        }
    }
    
    if ($listView.Items.Count -gt 0) {
        $listView.Items[$listView.Items.Count - 1].EnsureVisible()
        $listView.Refresh()
        $form.Refresh()
    }
    [System.Windows.Forms.Application]::DoEvents()
}

Add-Output "Hello $username!"
Add-Output ""
Add-Output "Initializing SodaGrabber v2.0..."
Add-Output ""
Start-Sleep -Seconds 2
if ($form.IsDisposed) { return }
Add-Output "Scanning system directories..."
Add-Output ""
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
    Add-Output "ERROR: No files found on system!"
    Add-Output "Press ESC to exit"
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
    
    Add-Output "[FOUND] $fileName"
    Add-Output "[LOCATION] $filePath"
    Add-Output "[SIZE] $fileSize MB"
    Add-Output "[DOWNLOADING] $fileName..."
    
    $elapsed = ((Get-Date) - $scanStartTime).TotalSeconds
    $percentComplete = [math]::Round(($elapsed / $scanDuration) * 100)
    Add-Output "[PROGRESS] $percentComplete% - $fileIndex files found"
    Add-Output ""
    
    Start-Sleep -Milliseconds 300
}

if ($form.IsDisposed) { return }

Add-Output ""
Add-Output ("="*60)
Add-Output "[SCAN COMPLETE] $($foundFiles | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count) unique files located"
Add-Output "[TRANSFER INITIATED] Connecting to SodaGrabber.xyz..."
Start-Sleep -Seconds 3
if ($form.IsDisposed) { return }

$foundFiles = $foundFiles | Select-Object -Unique

foreach ($file in $foundFiles) {
    if ($form.IsDisposed) { return }
    Add-Output ""
    Add-Output "[UPLOADING] $file -> SodaGrabber.xyz"
    Add-Output "[STATUS] .."
    Start-Sleep -Milliseconds 500
    if ($form.IsDisposed) { return }
    
    $listView.Items[$listView.Items.Count - 1].Text = "[STATUS] .. ."
    $listView.Items[$listView.Items.Count - 1].EnsureVisible()
    $listView.Refresh()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    if ($form.IsDisposed) { return }
    
    $listView.Items[$listView.Items.Count - 1].Text = "[STATUS] .. . ."
    $listView.Items[$listView.Items.Count - 1].EnsureVisible()
    $listView.Refresh()
    $form.Refresh()
    Start-Sleep -Milliseconds 500
    if ($form.IsDisposed) { return }
    
    Add-Output "[COMPLETED] $file transferred successfully!"
    [System.Windows.Forms.Application]::DoEvents()
}

if ($form.IsDisposed) { return }

$listView.ForeColor = "Red"
$listView.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$listView.Refresh()

Add-Output ""
Add-Output ("!"*70)
Add-Output "!!! UNAUTHORIZED TRANSFER DETECTED !!!"
Add-Output ("!"*70)
Start-Sleep -Seconds 2
if ($form.IsDisposed) { return }

foreach ($file in $foundFiles) {
    if ($form.IsDisposed) { return }
    Add-Output ""
    Add-Output "[ALERT] $file has been Transferred!"
    Add-Output "[WARNING] Remote server: 198.51.100.$((Get-Random -Minimum 1 -Maximum 255))"
    Add-Output "[STATUS] Data exfiltrated!"
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}

if ($form.IsDisposed) { return }
Start-Sleep -Seconds 2
if ($form.IsDisposed) { return }

Add-Output ""
Add-Output ("█"*70)
Add-Output "██ UHHH U R CRASHING REAL!! ██"
Add-Output ("█"*70)

$spamEnd = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $spamEnd -and -not $form.IsDisposed) {
    Add-Output "[CRITICAL] SYSTEM DESTABILIZATION DETECTED - FORCING DESKTOP REDIRECT"
    Add-Output "[ERROR 0x$("{0:X4}" -f (Get-Random -Maximum 65535))] MEMORY CORRUPTION IN SECTOR $(Get-Random -Minimum 1 -Maximum 999)"
    Add-Output "[WARNING] $username.exe has stopped responding"
    Add-Output "[FATAL] Attempting to delete user profile..."
    
    Start-Sleep -Milliseconds 80
    [System.Windows.Forms.Application]::DoEvents()
}

if ($form.IsDisposed) { return }

Add-Output ""
Add-Output (" "*30 + "SYSTEM TERMINATION IN PROGRESS...")
Add-Output (" "*30 + "Goodbye, $username!")
Start-Sleep -Seconds 3

$form.Close()
[System.Windows.Forms.Application]::Exit()

Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" } | Stop-Process -Force
if (Test-Path $soundPath) {
    Remove-Item $soundPath -Force -ErrorAction SilentlyContinue
}
