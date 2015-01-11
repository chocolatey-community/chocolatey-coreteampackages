﻿$packageName = 'chromium'
$url = 'http://commondatastorage.googleapis.com/chromium-browser-continuous/Win/228899/mini_installer.exe'
$filePath = "$env:TEMP\chocolatey\$packageName"
$fileFullPath = "$filePath\${packageName}Install.exe"

try {
    if (!(Test-Path $filePath)) {
        New-Item -ItemType directory -Path $filePath
    }

    Get-ChocolateyWebFile $packageName $fileFullPath $url
    Start-Process $fileFullPath

    Write-ChocolateySuccess $packageName
} catch {
    Write-ChocolateyFailure $packageName $($_.Exception.Message)
    throw
}