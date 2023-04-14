function sambaWorker {
    param($rhosts)

    $rport = 445
    $timeout = 1

    foreach ($rhost in $rhosts){
        try {
            $t = new-Object system.Net.Sockets.TcpClient
            $c = $t.BeginConnect($rhost, $rport, $null, $null)
            $w = $c.AsyncWaitHandle.WaitOne($timeout * 1000, $false)

            if (!$w) {
                $t.Close()

                Write-Output "$rhost on $rport, $w"
            } else {
                    $null = $t.EndConnect($c)

                    Write-Output "$rhost on $rport, $w"
                    
                    $t.Close()
                }
        } catch {
            return $false
        }
    }
}

$from = "192.168.0.1"
$to = "192.168.0.255"

$ipAdressIn = $from -split "\."
$ipAdressOut = $to -split "\."

$rhosts = New-Object System.Collections.ArrayList

[array]::Reverse($ipAdressIn)
[array]::Reverse($ipAdressOut)

$start=[bitconverter]::ToUInt32([byte[]]$ipAdressIn,0)
$end=[bitconverter]::ToUInt32([byte[]]$ipAdressOut,0)

for ($ip = $start; $ip -lt $end; $ip++)
{ 
    $get_ip=[bitconverter]::getbytes($ip)

    [array]::Reverse($get_ip)

    $rhosts.Add($get_ip -join "." -split "`n")
}

sambaWorker $rhosts

$rhosts.Clear()