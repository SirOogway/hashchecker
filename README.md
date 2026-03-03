# HashChecker

Lightweight Windows GUI application built with PowerShell to verify file integrity by comparing cryptographic hashes.

<div>
  <img src="https://github.com/SirOogway/hashchecker/blob/main/Assets/preview1.PNG?raw=true" width="300"/>
  <img src="https://github.com/SirOogway/hashchecker/blob/main/Assets/preview2.png?raw=true" width="300"/>
  <img src="https://github.com/SirOogway/hashchecker/blob/main/Assets/preview3.png?raw=true" width="300"/>
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

## Disclaimer

HashChecker verifies file integrity but does not repair corrupted files.
