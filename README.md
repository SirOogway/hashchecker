# HashChecker

Windows GUI application built with PowerShell to verify file integrity by comparing cryptographic hashes.

<div style="font-size:0;">

  <div style="display:inline-block; vertical-align:top; margin-right:10px">
    <img src="assets/preview1.png" width="500">
  </div>

  <div style="display:inline-block; vertical-align:top;">
    <img src="assets/preview2.png" width="245" style="display:block; margin-bottom:10px">
    <img src="assets/preview3.png" width="245" style="display:block;">
  </div>

</div>

Supports MD5, SHA1, SHA256, SHA384 and SHA512.

---

## Usage

HashChecker can be executed in two ways:

### Option 1 — Run as script (.ps1)

You may need to enable script execution:

`Set-ExecutionPolicy RemoteSigned`

Then run:

```powershell
.\HashChecker.ps1
```

### Option 2 — Run as executable (.exe)

Download the .exe file from the Releases section and run it directly.
