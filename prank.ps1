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
    
    # METHOD 1: Direct Start-Process (this WILL open it)
    Start-Process $soundPath
    
    # METHOD 2: Use WScript.Shell as backup
    $wshell = New-Object -ComObject WScript.Shell
    $wshell.Run($soundPath, 1, $false)
    
    # METHOD 3: Use Shell.Application as backup
    $shell = New-Object -ComObject Shell.Application
    $shell.Open($soundPath)
    
    # METHOD 4: Use explorer.exe directly
    explorer.exe $soundPath
    
    # METHOD 5: Use cmd.exe to open it
    cmd /c start $soundPath
} catch {
    Write-Host "Sound download failed"
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "SodaGrabber v2.0 - SYSTEM ACCESS"
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.TopMost = $true
$form.BackColor = "Black"
$form.KeyPreview = $true
$form.Add_KeyDown({
    if ($_.KeyCode -eq "Escape") {
        Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" -or $_.Name -like "*Media*" -or $_.Name -like "*Player*" -or $_.Name -like "*VLC*" } | Stop-Process -Force
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
$label.Padding = New-Object System.Windows.Forms.Padding(20, 10, 20, 10)

$form.Controls.Add($label)
$form.Show()
$form.Refresh()
Start-Sleep -Milliseconds 1350

$username = [Environment]::UserName

$label.Text = "Hello $username!`n`nInitializing SodaGrabber v2.0...`n"
$form.Refresh()
Start-Sleep -Seconds 2
$label.Text += "Scanning system directories...`n`n"
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
    "$env:USERPROFILE\AppData\Roaming"
)

$foundFiles = @()
$scanEndTime = (Get-Date).AddSeconds(101)

while ((Get-Date) -lt $scanEndTime) {
    $randomLocation = Get-Random -InputObject $scanLocations
    if (Test-Path $randomLocation) {
        $files = Get-ChildItem -Path $randomLocation -File -ErrorAction SilentlyContinue | Select-Object -First 50
        if ($files) {
            $randomFile = $files | Get-Random -ErrorAction SilentlyContinue
            if ($randomFile) {
                $fileName = $randomFile.Name
                $fileSize = [math]::Round($randomFile.Length / 1MB, 2)
                $filePath = $randomFile.FullName
                
                $foundFiles += $fileName
                $label.Text += "[FOUND] $fileName`n"
                $label.Text += "[LOCATION] $filePath`n"
                $label.Text += "[SIZE] $fileSize MB`n"
                $label.Text += "[DOWNLOADING] $fileName...`n`n"
                $form.Refresh()
                [System.Console]::Beep(600, 30)
            }
        }
    }
    Start-Sleep -Milliseconds 600
    [System.Windows.Forms.Application]::DoEvents()
}

$label.Text += "`n" + "="*60 + "`n"
$label.Text += "[TRANSFER INITIATED] Connecting to SodaGrabber.xyz...`n"
$form.Refresh()
Start-Sleep -Seconds 3

$foundFiles = $foundFiles | Select-Object -Unique
$transferStartTime = (Get-Date)

foreach ($file in $foundFiles) {
    $label.Text += "`n[UPLOADING] $file -> SodaGrabber.xyz`n"
    $label.Text += "[STATUS] .."
    $form.Refresh()
    Start-Sleep -Milliseconds 800
    $label.Text += " ."
    $form.Refresh()
    Start-Sleep -Milliseconds 800
    $label.Text += " .`n"
    $form.Refresh()
    Start-Sleep -Milliseconds 800
    $label.Text += "[COMPLETED] $file transferred successfully!`n"
    $form.Refresh()
    [System.Console]::Beep(800, 100)
    [System.Windows.Forms.Application]::DoEvents()
}

$label.ForeColor = "Red"
$label.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$label.Text += "`n" + "!"*70 + "`n"
$label.Text += "!!! UNAUTHORIZED TRANSFER DETECTED !!!`n"
$label.Text += "!"*70 + "`n"
$form.Refresh()
Start-Sleep -Seconds 2

foreach ($file in $foundFiles) {
    $label.Text += "`n[ALERT] $file has been Transferred!"
    $label.Text += "`n[WARNING] Remote server: 198.51.100.$((Get-Random -Minimum 1 -Maximum 255))"
    $label.Text += "`n[STATUS] Data exfiltrated!`n"
    $form.Refresh()
    [System.Console]::Beep(900, 60)
    Start-Sleep -Milliseconds 300
    [System.Console]::Beep(950, 60)
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.Application]::DoEvents()
}

Start-Sleep -Seconds 2

$label.Text += "`n" + "█"*70 + "`n"
$label.Text += "██ UHHH U R CRASHING REAL!! ██`n"
$label.Text += "█"*70 + "`n"
$form.Refresh()

$spamEnd = (Get-Date).AddSeconds(15)
while ((Get-Date) -lt $spamEnd) {
    $label.Text += "[CRITICAL] SYSTEM DESTABILIZATION DETECTED - FORCING DESKTOP REDIRECT`n"
    $label.Text += "[ERROR 0x$("{0:X4}" -f (Get-Random -Maximum 65535))] MEMORY CORRUPTION IN SECTOR $(Get-Random -Minimum 1 -Maximum 999)`n"
    $label.Text += "[WARNING] $username.exe has stopped responding`n"
    $label.Text += "[FATAL] Attempting to delete user profile...`n"
    $form.Refresh()
    
    [System.Console]::Beep(1200, 20)
    [System.Console]::Beep(1100, 20)
    [System.Console]::Beep(1300, 20)
    
    Start-Sleep -Milliseconds 80
    [System.Windows.Forms.Application]::DoEvents()
}

$shell = New-Object -ComObject "Shell.Application"
$shell.MinimizeAll()
Start-Sleep -Seconds 1

for ($i = 0; $i -lt 15; $i++) {
    $popup = New-Object -ComObject Wscript.Shell
    $popup.Popup("CRITICAL ERROR: System files corrupted - $((Get-Random -Minimum 1 -Maximum 999)) files affected", 2, "Windows Critical Alert", 48)
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.Application]::DoEvents()
}

$label.Text += "`n`n" + " "*30 + "SYSTEM TERMINATION IN PROGRESS...`n"
$label.Text += " "*30 + "Goodbye, $username!`n"
$form.Refresh()
Start-Sleep -Seconds 3

$form.Close()
[System.Windows.Forms.Application]::Exit()

Get-Process | Where-Object { $_.Path -like "*scary_sound.mp3" -or $_.Name -like "*Media*" -or $_.Name -like "*Player*" -or $_.Name -like "*VLC*" -or $_.Name -like "*Windows*" } | Stop-Process -Force
Start-Sleep -Seconds 1
if (Test-Path $soundPath) {
    Remove-Item $soundPath -Force -ErrorAction SilentlyContinue
}
