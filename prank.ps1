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
        Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" } | Stop-Process -Force
        $form.Close()
        [System.Windows.Forms.Application]::Exit()
    }
})

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.ForeColor = "Lime"
$listBox.BackColor = "Black"
$listBox.Font = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Bold)
$listBox.Dock = "Fill"
$listBox.BorderStyle = "None"
$listBox.ScrollAlwaysVisible = $true
$listBox.HorizontalScrollbar = $false
$listBox.IntegralHeight = $false
$listBox.SelectionMode = "None"

$form.Controls.Add($listBox)
$form.Show()
$form.Refresh()
Start-Sleep -Milliseconds 1350

$username = [Environment]::UserName

$listBox.Items.Add("Hello $username!")
$listBox.Items.Add("")
$listBox.Items.Add("Initializing SodaGrabber v2.0...")
$listBox.Items.Add("")
$form.Refresh()
Start-Sleep -Seconds 2
$listBox.Items.Add("Scanning system directories...")
$listBox.Items.Add("")
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
$filePaths = @()
$fileSizes = @()
$scanStartTime = Get-Date
$scanDuration = 101
$scanEndTime = $scanStartTime.AddSeconds($scanDuration)

# ONLY collect real files - NO FALLBACKS
$allFiles = @()
foreach ($location in $scanLocations) {
    if (Test-Path $location) {
        try {
            $files = Get-ChildItem -Path $location -File -ErrorAction SilentlyContinue -Recurse -Force -ErrorAction SilentlyContinue | 
                     Where-Object { $_.Length -gt 0 -and $_.Name -notlike "*System Volume Information*" }
            $allFiles += $files
        } catch {}
    }
}

$allFiles = $allFiles | Where-Object { $_.Name -ne $null } | Sort-Object { Get-Random }
$totalFiles = $allFiles.Count

if ($totalFiles -eq 0) {
    $listBox.Items.Add("ERROR: No files found on system!")
    $listBox.Items.Add("")
    $listBox.Items.Add("Press ESC to exit")
    $form.Refresh()
} else {
    $fileIndex = 0

    while ((Get-Date) -lt $scanEndTime -and $totalFiles -gt 0) {
        $currentFile = $allFiles[$fileIndex % $totalFiles]
        $fileIndex++
        
        $fileName = $currentFile.Name
        $fileSize = [math]::Round($currentFile.Length / 1MB, 2)
        $filePath = $currentFile.FullName
        
        $foundFiles += $fileName
        $filePaths += $filePath
        $fileSizes += $fileSize
        
        $listBox.Items.Add("[FOUND] $fileName")
        $listBox.Items.Add("[LOCATION] $filePath")
        $listBox.Items.Add("[SIZE] $fileSize MB")
        $listBox.Items.Add("[DOWNLOADING] $fileName...")
        
        $elapsed = ((Get-Date) - $scanStartTime).TotalSeconds
        $percentComplete = [math]::Round(($elapsed / $scanDuration) * 100)
        $listBox.Items.Add("[PROGRESS] $percentComplete% - $fileIndex files found")
        $listBox.Items.Add("")
        
        $listBox.TopIndex = $listBox.Items.Count - 1
        $form.Refresh()
        [System.Windows.Forms.Application]::DoEvents()
        
        $delay = Get-Random -Minimum 200 -Maximum 400
        Start-Sleep -Milliseconds $delay
    }

    $listBox.Items.Add("")
    $listBox.Items.Add("="*60)
    $listBox.Items.Add("[SCAN COMPLETE] $($foundFiles | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count) unique files located")
    $listBox.Items.Add("[TRANSFER INITIATED] Connecting to SodaGrabber.xyz...")
    $listBox.TopIndex = $listBox.Items.Count - 1
    $form.Refresh()
    Start-Sleep -Seconds 3

    $foundFiles = $foundFiles | Select-Object -Unique
    $filePaths = $filePaths | Select-Object -Unique
    $fileSizes = $fileSizes | Select-Object -Unique

    for ($i = 0; $i -lt $foundFiles.Count; $i++) {
        $file = $foundFiles[$i]
        $path = if ($i -lt $filePaths.Count) { $filePaths[$i] } else { "Unknown" }
        $size = if ($i -lt $fileSizes.Count) { $fileSizes[$i] } else { 0 }
        
        $listBox.Items.Add("")
        $listBox.Items.Add("[UPLOADING] $file -> SodaGrabber.xyz")
        $listBox.Items.Add("[FROM] $path")
        $listBox.Items.Add("[SIZE] $size MB")
        $listBox.Items.Add("[STATUS] ..")
        $listBox.TopIndex = $listBox.Items.Count - 1
        $form.Refresh()
        Start-Sleep -Milliseconds 500
        $listBox.Items[$listBox.Items.Count - 1] = "[STATUS] .. ."
        $form.Refresh()
        Start-Sleep -Milliseconds 500
        $listBox.Items[$listBox.Items.Count - 1] = "[STATUS] .. . ."
        $form.Refresh()
        Start-Sleep -Milliseconds 500
        $listBox.Items.Add("[COMPLETED] $file transferred successfully!")
        $listBox.TopIndex = $listBox.Items.Count - 1
        $form.Refresh()
        [System.Windows.Forms.Application]::DoEvents()
    }

    $listBox.Items.Add("")
    $listBox.Items.Add("!"*70)
    $listBox.Items.Add("!!! UNAUTHORIZED TRANSFER DETECTED !!!")
    $listBox.Items.Add("!"*70)
    $listBox.TopIndex = $listBox.Items.Count - 1
    $form.Refresh()
    Start-Sleep -Seconds 2

    for ($i = 0; $i -lt $foundFiles.Count; $i++) {
        $file = $foundFiles[$i]
        $listBox.Items.Add("")
        $listBox.Items.Add("[ALERT] $file has been Transferred!")
        $listBox.Items.Add("[WARNING] Remote server: 198.51.100.$((Get-Random -Minimum 1 -Maximum 255))")
        $listBox.Items.Add("[STATUS] Data exfiltrated!")
        $listBox.TopIndex = $listBox.Items.Count - 1
        $form.Refresh()
        [System.Windows.Forms.Application]::DoEvents()
        Start-Sleep -Milliseconds 100
    }

    Start-Sleep -Seconds 2

    $listBox.Items.Add("")
    $listBox.Items.Add("█"*70)
    $listBox.Items.Add("██ UHHH U R CRASHING REAL!! ██")
    $listBox.Items.Add("█"*70)
    $listBox.TopIndex = $listBox.Items.Count - 1
    $form.Refresh()

    $spamEnd = (Get-Date).AddSeconds(15)
    while ((Get-Date) -lt $spamEnd) {
        $listBox.Items.Add("[CRITICAL] SYSTEM DESTABILIZATION DETECTED - FORCING DESKTOP REDIRECT")
        $listBox.Items.Add("[ERROR 0x$("{0:X4}" -f (Get-Random -Maximum 65535))] MEMORY CORRUPTION IN SECTOR $(Get-Random -Minimum 1 -Maximum 999)")
        $listBox.Items.Add("[WARNING] $username.exe has stopped responding")
        $listBox.Items.Add("[FATAL] Attempting to delete user profile...")
        $listBox.TopIndex = $listBox.Items.Count - 1
        $form.Refresh()
        
        Start-Sleep -Milliseconds 80
        [System.Windows.Forms.Application]::DoEvents()
    }

    $listBox.Items.Add("")
    $listBox.Items.Add(" "*30 + "SYSTEM TERMINATION IN PROGRESS...")
    $listBox.Items.Add(" "*30 + "Goodbye, $username!")
    $listBox.TopIndex = $listBox.Items.Count - 1
    $form.Refresh()
    Start-Sleep -Seconds 3
}

$form.Close()
[System.Windows.Forms.Application]::Exit()

Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" } | Stop-Process -Force
if (Test-Path $soundPath) {
    Remove-Item $soundPath -Force -ErrorAction SilentlyContinue
}
