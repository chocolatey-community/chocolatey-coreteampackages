﻿$packageName = 'winff'
$fileType = 'exe'
$silentArgs = '/VERYSILENT'
$url = 'http://winff.googlecode.com/files/WinFF-1.5.0-setup.exe'
$url64bit = 'http://winff.googlecode.com/files/WinFF-1.5.0-win64-setup.exe'

Install-ChocolateyPackage $packageName $fileType $silentArgs $url $url64bit