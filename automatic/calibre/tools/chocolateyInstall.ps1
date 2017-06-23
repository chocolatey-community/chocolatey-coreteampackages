﻿$ErrorActionPreference = 'Stop'

$toolsPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  packageName    = $env:ChocolateyPackageName
  fileType       = 'MSI'
  file           = "$toolsPath\calibre-3.1.1.msi"
  file64         = "$toolsPath\calibre-64bit-3.1.1.msi"
  softwareName   = 'calibre*'
  silentArgs     = '/quiet'
  validExitCodes = @(0, 3010, 1641)
}
Install-ChocolateyInstallPackage @packageArgs

Remove-Item -Force -ea 0 "$toolsPath\*.msi","$toolsPath\*.ignore"
