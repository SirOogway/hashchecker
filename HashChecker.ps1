Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#region ========================= METADATA =========================

$Script:AppName    = "HashChecker"
$Script:AppVersion = "1.0.0"
$Script:AppYear    = (Get-Date).Year
$Script:Slogan     = "Integrity matters"

#endregion ========================================================

#region ========================= LOGIC =========================

function Get-NormalizedHash {
    param(
        [Parameter(Mandatory)]
        [string]$Hash
    )

    return ($Hash -replace '\s','').Trim().ToUpper()
}

function Get-FileHashSecure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$FilePath,

        [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512")]
        [string]$Algorithm = "SHA256"
    )

    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        $hashResult = Get-FileHash -Path $FilePath -Algorithm $Algorithm -ErrorAction Stop

        $stopwatch.Stop()

        return [PSCustomObject]@{
            Hash      = $hashResult.Hash.ToUpper()
            Algorithm = $Algorithm
            Duration  = $stopwatch.Elapsed
        }
    }
    catch {
        throw "Error calculando hash: $($_.Exception.Message)"
    }
}

function Test-FileIntegrity {
    param(
        [Parameter(Mandatory)] [string]$CalculatedHash,
        [Parameter(Mandatory)] [string]$ExpectedHash
    )

    return $CalculatedHash -eq (Get-NormalizedHash $ExpectedHash)
}

#endregion =======================================================

#region ========================= UI ==============================

$form = New-Object System.Windows.Forms.Form
$form.Text = "$Script:AppName v$Script:AppVersion"
$form.Size = New-Object System.Drawing.Size(480,450)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("Segoe UI",9)

# ===================== GROUP 1 - Hash =====================
$groupHash = New-Object System.Windows.Forms.GroupBox
$groupHash.Text = "Hash Configuration"
$groupHash.Location = New-Object System.Drawing.Point(15,15)
$groupHash.Size = New-Object System.Drawing.Size(440,120)
$form.Controls.Add($groupHash)

$labelHash = New-Object System.Windows.Forms.Label
$labelHash.Text = "Expected Hash"
$labelHash.Location = New-Object System.Drawing.Point(15,25)
$labelHash.AutoSize = $true
$groupHash.Controls.Add($labelHash)

$textHash = New-Object System.Windows.Forms.TextBox
$textHash.Location = New-Object System.Drawing.Point(15,47)
$textHash.Width = 400
$groupHash.Controls.Add($textHash)

$labelAlgo = New-Object System.Windows.Forms.Label
$labelAlgo.Text = "Hash algorithm"
$labelAlgo.Location = New-Object System.Drawing.Point(15,75)
$labelAlgo.AutoSize = $true
$groupHash.Controls.Add($labelAlgo)

$comboAlgorithm = New-Object System.Windows.Forms.ComboBox
$comboAlgorithm.Location = New-Object System.Drawing.Point(180,72)
$comboAlgorithm.Width = 150
$comboAlgorithm.DropDownStyle = "DropDownList"
$comboAlgorithm.Items.AddRange(@("MD5","SHA1","SHA256","SHA384","SHA512"))
$comboAlgorithm.SelectedItem = "SHA256"
$groupHash.Controls.Add($comboAlgorithm)

# ===================== GROUP 2 - Archivo =====================
$groupFile = New-Object System.Windows.Forms.GroupBox
$groupFile.Text = "File"
$groupFile.Location = New-Object System.Drawing.Point(15,145)
$groupFile.Size = New-Object System.Drawing.Size(440,100)
$form.Controls.Add($groupFile)

$buttonSelectFile = New-Object System.Windows.Forms.Button
$buttonSelectFile.Text = "Select file to verify"
$buttonSelectFile.Location = New-Object System.Drawing.Point(15,25)
$buttonSelectFile.Width = 250
$groupFile.Controls.Add($buttonSelectFile)

$labelFilePath = New-Object System.Windows.Forms.Label
$labelFilePath.Text = "No file selected"
$labelFilePath.Location = New-Object System.Drawing.Point(15,60)
$labelFilePath.Width = 400
$labelFilePath.AutoEllipsis = $true
$groupFile.Controls.Add($labelFilePath)

# ===================== GROUP 3 - Verificación =====================
$groupVerify = New-Object System.Windows.Forms.GroupBox
$groupVerify.Text = "Verification"
$groupVerify.Location = New-Object System.Drawing.Point(15,255)
$groupVerify.Size = New-Object System.Drawing.Size(440,110)
$form.Controls.Add($groupVerify)

$buttonVerify = New-Object System.Windows.Forms.Button
$buttonVerify.Text = "Verify integrity"
$buttonVerify.Location = New-Object System.Drawing.Point(15,25)
$buttonVerify.Width = 300
$buttonVerify.Enabled = $false
$groupVerify.Controls.Add($buttonVerify)

$labelResult = New-Object System.Windows.Forms.Label
$labelResult.Location = New-Object System.Drawing.Point(15,60)
$labelResult.Width = 400
$labelResult.Font = New-Object System.Drawing.Font("Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$groupVerify.Controls.Add($labelResult)

$labelDuration = New-Object System.Windows.Forms.Label
$labelDuration.Location = New-Object System.Drawing.Point(15,80)
$labelDuration.Width = 400
$groupVerify.Controls.Add($labelDuration)

# ===================== Marca centrada =====================
$watermark = New-Object System.Windows.Forms.Label
$watermark.Text = "$Script:Slogan · $Script:AppYear"
$watermark.AutoSize = $true
$watermark.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150)
$watermark.Font = New-Object System.Drawing.Font("Segoe UI",8,[System.Drawing.FontStyle]::Italic)
$form.Controls.Add($watermark)

$posX = [int](($form.ClientSize.Width - $watermark.Width) / 2)
$posY = $form.ClientSize.Height - $watermark.Height - 10
$watermark.Location = New-Object System.Drawing.Point($posX, $posY)

#endregion =======================================================

#region ========================= EVENTS ==========================

function Update-VerifyButtonState {

    $filePath = $labelFilePath.Text

    if (
        -not [string]::IsNullOrWhiteSpace($filePath) -and
        (Test-Path -Path $filePath -PathType Leaf -ErrorAction SilentlyContinue) -and
        -not [string]::IsNullOrWhiteSpace($textHash.Text)
    ) {
        $buttonVerify.Enabled = $true
    }
    else {
        $buttonVerify.Enabled = $false
    }
}

$textHash.Add_TextChanged({
    Update-VerifyButtonState
})

$buttonSelectFile.Add_Click({
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    if ($dialog.ShowDialog() -eq "OK") {
        $labelFilePath.Text = $dialog.FileName
        Update-VerifyButtonState
    }
    else {
        $labelFilePath.Text = "No file selected"
    }
})

$buttonVerify.Add_Click({

    $labelResult.Text = ""
    $labelDuration.Text = ""

    if ([string]::IsNullOrWhiteSpace($textHash.Text)) {
        $labelResult.Text = "You must enter the expected hash"
        $labelResult.ForeColor = "DarkOrange"
        return
    }

    try {
        $result = Get-FileHashSecure `
            -FilePath $labelFilePath.Text `
            -Algorithm $comboAlgorithm.SelectedItem.ToString()

        $isValid = Test-FileIntegrity `
            -CalculatedHash $result.Hash `
            -ExpectedHash $textHash.Text

        if ($isValid) {
            $labelResult.Text = "INTEGRITY CONFIRMED ($($result.Algorithm))"
            $labelResult.ForeColor = "Green"
        }
        else {
            $labelResult.Text = "FILE CORRUPTED ($($result.Algorithm))"
            $labelResult.ForeColor = "Red"
        }

        $labelDuration.Text = "Calculation time: $($result.Duration.TotalSeconds) seconds"
    }
    catch {
        $labelResult.Text = $_.Exception.Message
        $labelResult.ForeColor = "Red"
    }
})

#endregion =======================================================

[System.Windows.Forms.Application]::Run($form)