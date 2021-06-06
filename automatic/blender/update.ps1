﻿Import-Module AU

$releases = 'https://www.blender.org/download/'
$softwareName = 'Blender'

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }

function global:au_SearchReplace {
  @{
    ".\legal\VERIFICATION.txt" = @{
      "(?i)(^\s*location on\:?\s*)\<.*\>" = "`${1}<$releases>"
      "(?i)(\s*64\-Bit Software.*)\<.*\>" = "`${1}<$($Latest.URL64)>"
      "(?i)(^\s*checksum\s*type\:).*" = "`${1} $($Latest.ChecksumType64)"
      "(?i)(^\s*checksum64\:).*" = "`${1} $($Latest.Checksum64)"
    }
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
      "(?i)(^\s*file64\s*=\s*`"[$]toolsPath\\).*" = "`${1}$($Latest.FileName64)`""
    }
    ".\tools\chocolateyUninstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
    }
  }
}
function global:au_GetLatest {
  $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing

  #regex to find download url, it should match any url that ends with a 64 bit windows msi
  $re = '\/[^/]*windows.*64.*\.msi\/$'
  $url64 = $download_page.links | ? href -match $re | select -first 1 -expand href

  # this should get the version number based on Blender's version numbering as of 03-Jun-2020
  $version64 = $url64 -match '\d\.\d\d\.\d+' | Foreach {$Matches[0]}

  <# if block to replace a leter at end of version64 with '.1' should no longer be needed,
  see https://wiki.blender.org/wiki/Process/LTS#Version_Communication
  if ($version64 -match '[a-z]$') {
    [char]$letter = $version64[$version64.Length - 1]
    [int]$num = $letter - [char]'a'
    $num++
    $version64 = $version64 -replace $letter,".$num"
  }
  #>
  @{
    URL64 = Get-ActualUrl $url64
    Version = $version64
  }
}


function Get-ActualUrl() {
  param([string]$url)

  $request = [System.Net.WebRequest]::Create($url)

  $response = $request.GetResponse()

  $headers = $response.Headers

  if ($headers["refresh"]) {
    $res = $headers["refresh"] -split '[;=]' | select -last 1
  } else {
    $res = $url
  }

  $response.Dispose()
  return $res
}

update -ChecksumFor none
