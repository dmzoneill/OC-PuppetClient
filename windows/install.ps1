Write-Host "Downloading Puppet..."
$source = "http://puppet.ir.intel.com/bootstrap/windows/puppet-3.4.2.msi"
$destination = "c:\temp\puppet.msi"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile( $source, $destination )

Write-Host "Installing Puppet..."
msiexec /l*v install.txt /qn /i c:\temp\puppet.msi PUPPET_MASTER_SERVER=puppet.ir.intel.com PUPPET_AGENT_ENVIRONMENT=development_master | OUT-null

Get-Process ruby | Stop-Process -Confirm:$false -Force

Stop-Service -displayname "Puppet Agent" -Force

Write-Host "Downloading Puppet Config..."
$source = "http://puppet.ir.intel.com/bootstrap/windows/etc/puppet/puppet.conf"
$destination = "c:\ProgramData\PuppetLabs\puppet\etc\puppet.conf"
$wc = New-Object System.Net.WebClient
$wc.DownloadFile( $source, $destination )

Remove-Item -Recurse -Force "c:\ProgramData\PuppetLabs\puppet\etc\ssl"
New-Item -ItemType directory -Path "c:\ProgramData\PuppetLabs\puppet\etc\ssl"
New-Item -ItemType directory -Path "c:\ProgramData\PuppetLabs\puppet\etc\ssl\ca"
New-Item -ItemType directory -Path "c:\ProgramData\PuppetLabs\puppet\etc\ssl\certs"
New-Item -ItemType directory -Path "c:\ProgramData\PuppetLabs\puppet\etc\ssl\private_keys"

$source = "http://puppet.ir.intel.com/bootstrap/windows/etc/puppet/ssl/ca/ca_crt.pem"
$destination = "c:\ProgramData\PuppetLabs\puppet\etc\ssl\ca\ca_crt.pem"
$wc1 = New-Object System.Net.WebClient
$wc1.DownloadFile( $source, $destination )

$source = "http://puppet.ir.intel.com/bootstrap/windows/etc/puppet/ssl/certs/ca.pem"
$destination = "c:\ProgramData\PuppetLabs\puppet\etc\ssl\certs\ca.pem"
$wc2 = New-Object System.Net.WebClient
$wc2.DownloadFile( $source, $destination )

$source = "http://puppet.ir.intel.com/bootstrap/windows/etc/puppet/ssl/certs/puppetclient.intel.com.pem"
$destination = "c:\ProgramData\PuppetLabs\puppet\etc\ssl\certs\puppetclient.intel.com.pem"
$wc3 = New-Object System.Net.WebClient
$wc3.DownloadFile( $source, $destination )

$source = "http://puppet.ir.intel.com/bootstrap/windows/etc/puppet/ssl/private_keys/puppetclient.intel.com.pem"
$destination = "c:\ProgramData\PuppetLabs\puppet\etc\ssl\private_keys\puppetclient.intel.com.pem"
$wc4 = New-Object System.Net.WebClient
$wc4.DownloadFile( $source, $destination )

Start-Service -displayname "Puppet Agent"

Write-Host "Executing Puppet..."
"c:\Program Files (x86)\Puppet Labs\Puppet\bin\puppet_interactive.bat"

$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")