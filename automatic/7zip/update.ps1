import-module au

$domain   = 'http://www.7-zip.org/'
$releases = "${domain}download.html"

function global:au_SearchReplace {
  @{
    "$($Latest.PackageName).nuspec" = @{
      "(\<dependency .+?`"$($Latest.PackageName).install`" version=)`"([^`"]+)`"" = "`$1`"[$($Latest.Version)]`""
    }
  }
}

function global:au_GetLatest {
  $download_page = Invoke-WebRequest $releases

  $URLS = $download_page.links | ? href -match "7z.*\.exe$" | select -expand href

  $url32 = $URLS | ? { $_ -notmatch "x64" } | select -first 1
  $url64 = $URLS | ? { $_ -match "x64" } | select -first 1
  $url_extra = $download_page.links | ? href -match "7z.*extra\.7z" | select -first 1 -expand href

  $download_page.AllElements | ? innerText -match "^Download 7\-Zip ([\d\.]+)" | select -First 1 | Out-Null
  if ($Matches[1] -and ($Matches[1] -match '^[\d\.]+$')) { $version = $Matches[0] }

  @{
    URL32 = $domain + $url32
    URL64 = $domain + $url64
    URL_EXTRA = $domain + $url_extra
    Version = $version
    RemoteVersion = $version
  }
}

if ($MyInvocation.InvocationName -ne '.') {
  update -ChecksumFor none
}
