﻿$ErrorActionPreference = 'Stop'

$packageName = 'mp3tag'
$url32       = 'http://download.mp3tag.de/mp3tagv283setup.exe'
$checksum32  = '71f24569e2206b787d20246113df71a4973cb9acbc5fbd188c697a6c3ac5a450'
$silentArgs  = '/S'

$PSScriptRoot = Split-Path -parent $MyInvocation.MyCommand.Definition

# The installer doesn’t like being renamed. The installation wouldn’t be
# silent if it is renamed. Therefore the original filename is parsed
# from the URL
$installerPath = Join-Path $PSScriptRoot $url32.Split('/')[-1]
$iniFile = Join-Path $PSScriptRoot 'Mp3tagSetup.ini'

# Automatic language selection
$LCID = (Get-Culture).LCID
$iniContent = @"
[shortcuts]
startmenu=1
desktop=1
explorer=1

[language]
language=$LCID
"@

# Create the ini file for the installer
New-Item $iniFile -type file -force -value $iniContent

$packageArgs = @{
  packageName            = $packageName
  fileFullPath           = $installerPath
  fileType               = 'EXE'
  url                    = $url32
  checksum               = $checksum32
  checksumType           = 'sha256'
}

Get-ChocolateyWebFile @packageArgs

# Download the file to $PSScriptRoot.
# Using Chocolatey’s Installer-ChocolateyPackage function isn’t a good idea here
# because the path where the installer is downloaded could change and
# the ini file needs to be in the same folder to work.
Install-ChocolateyInstallPackage $packageName $fileType $silentArgs $installerPath
