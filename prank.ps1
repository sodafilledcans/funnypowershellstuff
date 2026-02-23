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
Add-Type -AssemblyName System.Media

$soundUrl = "https://raw.githubusercontent.com/sodafilledcans/funnypowershellstuff/main/ScarySound.mp3"
$soundPath = "$env:TEMP\scary_sound.mp3"

try {
    Invoke-WebRequest -Uri $soundUrl -OutFile $soundPath -ErrorAction Stop
} catch {
    Write-Host "Sound download failed, using beeps instead"
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "SYSTEM ALERT"
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
$label.Font = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
$label.Text = ""
$label.AutoSize = $false
$label.Size = New-Object System.Drawing.Size($form.Width, $form.Height)
$label.TextAlign = "TopLeft"
$label.Padding = New-Object System.Windows.Forms.Padding(50)

$form.Controls.Add($label)

$form.Show()
$form.Refresh()
Start-Sleep -Milliseconds 1350

$username = [Environment]::UserName

$fakeFiles = @(
    "passwords.txt", "bank_details.doc", "photos.zip", "browsing_history.dat",
    "private_keys.asc", "wallet.dat", "contacts.csv", "messages.db",
    "documents.tar", "system_backup.zip", "config.json", "credentials.xml",
    "credit_cards.txt", "ssh_keys.ppk", "database.sql", "personal_docs.pdf",
    "cookies.db", "history.log", "encrypted_files.gpg", "recovery_keys.txt"
)

$label.Text = "Hello $username!`n`nDownloading and Transferring Files...`n"
$form.Refresh()
Start-Sleep -Seconds 1

if (Test-Path $soundPath) {
    $sound = New-Object System.Media.SoundPlayer
    $sound.SoundLocation = $soundPath
    $sound.PlayLooping()
}

$counter = 1
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000

function Play-Tick {
    [System.Console]::Beep(800, 50)
}

$timer.Add_Tick({
    Play-Tick
    $randomFile = Get-Random -InputObject $fakeFiles
    $randomSize = Get-Random -Minimum 1 -Maximum 50
    $randomProgress = Get-Random -Minimum 10 -Maximum 100
    $label.Text += "[$counter] $randomFile - $randomProgress% complete ($randomSize MB)`n"
    $form.Refresh()
    $counter++
    
    if ($counter -gt 12) {
        $timer.Stop()
        if ($sound) { $sound.Stop() }
        Start-WarningSequence
    }
})
$timer.Start()

function Start-WarningSequence {
    $label.ForeColor = "Red"
    $label.Font = New-Object System.Drawing.Font("Consolas", 16, [System.Drawing.FontStyle]::Bold)
    $label.Text = "`n`n`n`n`n`n`n`n`n`n`n`n`n`n`n" + "█" * 70 + "`n"
    $label.Text += "██  WARNING! UNAUTHORIZED ACCESS DETECTED!  ██`n"
    $label.Text += "██  SYSTEM COMPROMISED!                     ██`n"
    $label.Text += "██  INITIATING EMERGENCY PROTOCOL...        ██`n"
    $label.Text += "█" * 70
    
    for ($i = 0; $i -lt 20; $i++) {
        $label.Text += "`n[ALERT #$($i+1)] CRITICAL SECURITY BREACH - CONTACT ADMINISTRATOR IMMEDIATELY"
        [System.Console]::Beep(1000 + ($i * 50), 80)
        $form.Refresh()
        Start-Sleep -Milliseconds 80
    }
    
    for ($i = 0; $i -lt 30; $i++) {
        $label.Text += "`n[ERROR 0x$("{0:X4}" -f (Get-Random -Maximum 65535))] ACCESS VIOLATION - SHUTTING DOWN..."
        [System.Console]::Beep(1200, 30)
        $form.Refresh()
        Start-Sleep -Milliseconds 30
    }
    
    Start-Sleep -Seconds 2
    
    $label.ForeColor = "Black"
    $label.BackColor = "Black"
    $form.BackColor = "Black"
    $label.Text = ""
    $form.Refresh()
    
    for ($i = 0; $i -lt 15; $i++) {
        [System.Console]::Beep(500 - ($i * 20), 400)
        [System.Console]::Beep(300 - ($i * 10), 200)
        Start-Sleep -Milliseconds 400
    }
    
    Start-Sleep -Seconds 3
    
    $form.BackColor = "White"
    $form.Refresh()
    Start-Sleep -Milliseconds 200
    
    $form.BackColor = "Control"
    $label.ForeColor = "Black"
    $label.BackColor = "Control"
    $label.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 24, [System.Drawing.FontStyle]::Bold)
    $label.Text = "`n`n`n`n`n`n`n`n`n`n" + " "*40 + "SYSTEM RESTORED`n`n" + " "*35 + "Just kidding! 😊`n`n`n`n" + " "*30 + "Press any key to exit..."
    $form.Refresh()
    
    $form.Add_KeyDown({
        $form.Close()
        [System.Windows.Forms.Application]::Exit()
    })
}

while ($form.Visible) {
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}

if (Test-Path $soundPath) {
    Remove-Item $soundPath -Force -ErrorAction SilentlyContinue
}
