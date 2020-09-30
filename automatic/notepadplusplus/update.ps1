import-module au


function global:au_SearchReplace {
  @{
        "$($Latest.PackageName).nuspec" = @{
            "(\<dependency .+?`"$($Latest.PackageName).install`" version=)`"([^`"]+)`"" = "`$1`"[$($Latest.Version)]`""
        }
    }
 }

function global:au_GetLatest {
    $tags = "https://github.com/notepad-plus-plus/notepad-plus-plus/tags"
    $release = Invoke-WebRequest $tags -UseBasicParsing
    $new = (( $release.links -match "\/v\d+\.\d+(\.\d+)?" ) -split " " | select -First 10 | Select -Last 1 )
    $new = $new.Substring(1,$new.Length-2)
    if ($new -eq "7.9") {
      $new = $new + ".RC4"
    }
    $releases = "http://download.notepad-plus-plus.org/repository/$($new -replace "^(\d+)\..*$","`$1").x/$new/"
    $download_page = Invoke-WebRequest $releases -UseBasicParsing
    $url_i         = $download_page.Links | ? href -match '.exe$' | Select-Object -Last 2 | % { $releases + $_.href }
    $url_p         = $download_page.Links | ? href -match '.7z$' | % { $releases + $_.href }

    $fixedVer
    if ($new -eq "7.9.RC4") {
      $fixedVer = "7.9"
    } else {
      $fixedVer = Split-Path (Split-Path $url_i[0]) -Leaf
    }

    @{
        Version = $fixedVer
        URL32_i = $url_i -notmatch 'x64' | select -First 1
        URL64_i = $url_i -match 'x64'  | select -First 1
        URL32_p = $url_p -notmatch 'x64' -notmatch 'minimalist'  | select -First 1
        URL64_p = $url_p -match 'x64' -notmatch 'minimalist'  | select -First 1
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    update -ChecksumFor none
}
