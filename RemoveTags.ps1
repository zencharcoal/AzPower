$subs = Get-AzSubscription

$tagname = "SecOpsContactEmail"
$tagvalue = "gaurav.batra@zf.com"

$subs | % {
    Set-AzContext $_
    $rs = Get-AzResource -TagName $tagname -TagValue $tagvalue
    $rs | % {
        $_.Tags.Remove($tagname)
        $_ | Set-AzResource -Force
    }  
}
