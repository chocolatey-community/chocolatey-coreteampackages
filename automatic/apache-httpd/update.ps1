Import-Module au
Import-module "$PSScriptRoot\..\..\scripts\au_extensions.psm1"

function global:au_AfterUpdate { Set-DescriptionFromReadme -SkipFirst 1 }

function global:au_GetLatest {
    $downloadPageUrl = 'http://www.apachehaus.com/cgi-bin/download.plx'
    $versionRegEx = 'httpd\-([0-9\.]+)\-x\d+\-(.*)\.zip'
    $url32 = 'https://www.apachehaus.com/downloads/httpd-$version-x86-$vcNumber.zip'
    $url64 = 'https://www.apachehaus.com/downloads/httpd-$version-x64-$vcNumber.zip'

    $downloadPage = Invoke-WebRequest $downloadPageUrl -UseBasicParsing
    $matches = [regex]::match($downloadPage.Content, $versionRegEx)
    $version = [version]$matches.Groups[1].Value
    $vcNumber = $matches.Groups[2].Value

    $url32 = $ExecutionContext.InvokeCommand.ExpandString($url32)
    $url64 = $ExecutionContext.InvokeCommand.ExpandString($url64)

    $info = @{ Url32 = $url32; Url64 = $url64; Version = $version }

    write-host $($info | out-string)
    return $info
}

function global:au_SearchReplace {
    return @{
        ".\tools\chocolateyInstall.ps1" = @{
            "(?i)(^\s*url\s*=\s*)('.*')"        = "`$1'$($Latest.Url32)'"
            "(?i)(^\s*url64\s*=\s*)('.*')"      = "`$1'$($Latest.Url64)'"
            "(?i)(^\s*checksum\s*=\s*)('.*')"   = "`$1'$($Latest.Checksum32)'"
            "(?i)(^\s*checksum64\s*=\s*)('.*')" = "`$1'$($Latest.Checksum64)'"
        }
    }
}

update
