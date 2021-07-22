$ErrorActionPreference = 'Stop';

$packageName   = $env:ChocolateyPackageName
$toolsDir      = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$packageArgs = @{
  PackageName    = $packageName
  FileFullPath64 = Get-Item $toolsDir\k9s_*Windows_x86_64.tar.gz
  Destination    = $toolsDir
}

Get-ChocolateyUnzip @packageArgs

$packageArgs2 = @{
  PackageName    = $packageName
  FileFullPath64 = Get-Item $toolsDir\k9s_*Windows_x86_64.tar
  Destination    = $toolsDir
}

Get-ChocolateyUnzip @packageArgs2

Remove-Item "$toolsDir\k9s_*Windows_*.tar"
