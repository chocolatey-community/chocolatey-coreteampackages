﻿$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  softwareName = "Lightscreen*"
  file         = "$toolsDir\LightscreenSetup-2.5.exe"
  fileType     = "exe"
  silentArgs   = "/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP- /LAUNCHAFTER=0"
}

Install-ChocolateyInstallPackage @packageArgs

for ($i=0; $i -lt 3; $i++) { Start-Sleep 1; $p = Get-Process LightScreen -ea 0; if ($p) { $p | Stop-Process; Write-Host "Process killed:" $p.Name; break }  }

Get-ChildItem -Path $toolsDir\*.exe | ForEach-Object { Remove-Item $_ -ea 0; if (Test-Path $_) { Set-Content "$_.ignore" } }
