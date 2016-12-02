Function Get-FosshubWebFile() {
  param(
    [parameter(Mandatory=$true, Position=0)][string] $packageName,
    [parameter(Mandatory=$false, Position=2)][string] $url = '',
    [parameter(Mandatory=$false, Position=3)]
    [alias("url64")][string] $url64bit = $url,
    [parameter(Mandatory=$false)][string] $checksum = '',
    [parameter(Mandatory=$false)][string] $checksumType = '',
    [parameter(Mandatory=$false)][string] $checksum64 = $checksum,
    [parameter(Mandatory=$false)][string] $checksumType64 = $checksumType,
    [parameter(Mandatory=$false)][hashtable] $options = @{Headers=@{}},
    [parameter(Mandatory=$false)][switch] $forceDownload,
    [parameter(ValueFromRemainingArguments = $true)][Object[]] $ignoredArguments
  )

  Write-FunctionCallLogMessage -Invocation $MyInvocation -Parameters $PSBoundParameters

  if ($url -ne $null) { $url = $url.Replace('//', '/').Replace(':/', '://') }
  if ($url64bit -ne $null) { $url64bit = $url64bit.Replace('//', '/').Replace(':/', '://') }

  $url32bit = $url

  # allow user provided values for checksumming
  $checksum32Override = $env:chocolateyChecksum32
  $checksumType32Override = $env:chocolateyChecksumType32
  $checksum64Override = $env:chocolateyChecksum64
  $checksumType64Override = $env:chocolateyChecksumType64
  if ($checksum32Override -ne $null -and $checksum32Override -ne '') { $checksum = $checksum32Override }
  if ($checksumType32Override -ne $null -and $checksumType32Override -ne '') { $checksumType = $checksumType32Override }
  if ($checksum64Override -ne $null -and $checksum64Override -ne '') { $checksum64 = $checksum64Override }
  if ($checksumType64Override -ne $null -and $checksumType64Override -ne '') { $checksumType64 = $checksumType64Override }

  $checksum32 = $checksum
  $checksumType32 = $checksumType
  $bitWidth = 32
  if (Get-ProcessorBits 64) { $bitWidth = 64 }

  Write-Debug "CPU is $bitWidth bit"

  $bitPackage = ''

  if ($url32bit -ne $url64bit -and $url64bit -ne $null -and $url64bit -ne '') { $bitPackage = '32 bit' }

  if ($bitWidth -eq 64 -and $url64bit -ne $null -and $url64bit -ne '') {
    Write-Debug "Setting url to '$url64bit' and bitPackage to $bitWidth"
    $bitPackage = '64 bit'
    $url = $url64bit
    if ($url32bit -ne $url64bit) {
      $checksum = $checksum64
      if ($checksumType64 -ne '') {
        $checksumType = $checksumType64
      }
    }
  }

  $forceX86 = $env:chocolateyForceX86
  if ($forceX86) {
    Write-Debug "User specified -x86 so forcing 32 bit"
    if ($url32bit -ne $url64bit) { $bitPackage = '32 bit' }
    $url = $url32bit
    $checksum = $checksum32
  }

  # If we're on 32 bit or attempting to force 32 bit and there is no
  # 32 bit url, we need to throw an error.
  if ($url -eq $null -or $url -eq '') {
    throw "This package does not support $bitWidth bit architecture."
  }

  if ($url.StartsWith('http:')) {
    $url = $url.Replace('http://', 'https://')
    Write-Warning "Fosshub supports SSL, switching to HTTPS for download."
  }

  $fileName = getFosshubFileName $url
  $fileDirectory = Get-PackageCacheLocation
  $fileFullPath = Join-Path $fileDirectory $fileName

  $needsDownload = $true
  $fiCached = New-Object System.IO.FileInfo($fileFullPath)
  if ($fiCached.Exists -and -not ($forceDownload)) {
    if ($checksum -ne $null -and $checksum -ne '') {
      try {
        Write-Host "File appears to be downloaded already. Verifying with package checksums to determine if it needs to be redownloaded."
        Get-ChecksumValid -file $fileFullPath -checkSum $checksum -checksumType $checksumType -ErrorAction "Stop"
        $needsDownload = $false
      } catch {
        Write-Debug "Existing file failed checksum. Will be redownloaded from url."
      }
    }
  }

  if ($needsDownload) {
    if (!($options["Headers"].ContainsKey('Referer'))) {
      $referer = getFosshubReferer $url
      $options["Headers"].Add('Referer', $referer)
    }
    $downloadUrl = get-UrlFromFosshub $url
    Get-WebFile -Url $downloadUrl -FileName $fileFullPath -Options $options
  }

  Start-Sleep 2

  $fi = New-Object System.IO.FileInfo($fileFullPath)
  if (!($fi.Exists)) { throw "Chocolatey expected a file to be downloaded to `'$fileFullPath`' but nothing exists at that location." }

  Get-VirusCheckValid -Location $url -File $fileFullPath

  if ($needsDownload -and ($checksum -ne $null -and $checksum -ne '')) {
    Write-Debug "Verifying package provided checksum fo '$checksum' for '$fileFullPath'."
    Get-ChecksumValid -File $fileFullPath -Checksum $checksum -ChecksumType $checksumType -OriginalUrl $url
  }

  return $fileFullPath
}


function getFosshubFileName() {
  param([string]$linkUrl)

  $linkUrl -match 'fosshub.com/(.*)/(.*)' | Out-Null
  if (!$Matches) {
    return''
  } else {
    return $Matches[2]
  }
}

function getFosshubReferer() {
  param([string]$linkUrl)

  $linkUrl -match 'fosshub.com/(.*)/' | Out-Null

  if (!$Matches) {
    return ''
  } else {
    "https://www.fosshub.com/$($Matches[1])"
  }
}
