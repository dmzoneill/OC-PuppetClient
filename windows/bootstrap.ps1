$source = "http://puppet.ir.intel.com/bootstrap/windows/install.ps1"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile( $source , "C:\temp\install.ps1" )
Start-Process powershell.exe '& C:\temp\install.ps1'
