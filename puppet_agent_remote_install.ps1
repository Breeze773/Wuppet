##Static Variables
$64installer = "puppet-enterprise-3.7.2-x64.msi"
$632installer = "puppet-enterprise-3.7.2.msi"
$destdir = "c:\temp"
$service_user = "<Some Service User>"
$computers = get-content .\computers.txt
$service_user_pw = Read-Host "Please enter the password for the $service_user user" -AsSecureString
$pw = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($service_user_pw))
$computers | where{test-connection $_ -quiet -count 1} | ForEach-Object{
$destinationFolder = "\\$_\C$\Temp"
$networkLocation = "\\some\network\share"
$puppetMaster = "<some puppet master>"
$domain = "<some domain>"
##Dynamic Variables
$arch = (get-wmiobject win32_operatingsystem -computer $_ | select-object OSArchitecture).OSArchitecture
$scriptBlockContent = {param($script:installer,$service_user,$pw) cmd /K msiexec /qn /i $script:installer 
					PUPPET_MASTER_SERVER=$puppetMaster
					PUPPET_AGENT_ACCOUNT_DOMAIN=$domain
					PUPPET_AGENT_ACCOUNT_USER=$service_user
					PUPPET_AGENT_ACCOUNT_PASSWORD=$pw
					}

Write-Host "Beginning Puppet Installation on computers in the computers.txt file"
function See-PuppetInstalled() {
	$time = Get-Date -format T
	Write-Host "Checking for previous installation of Puppet on $_ starting at: $time"
	$puppetInstalled=(Get-WmiObject -Class Win32_Product -computername $_ | sort-object Name | select Name | where { $_.Name -match 'Puppet'}).Name
	if ($puppetInstalled -eq "Puppet Enterprise (64-bit)") {
		Write-Host "Looks like Puppet is already installed on $_ so skipping the install."
		Return "$script:installed"
	}
	else {
	Write-Host "Did not detect a Puppet installation on $_.  Installing it now."
	Install-Puppet
	}
}
function Install-Puppet(){
	if ("$arch" -eq "64-bit")
		{ $script:path = "$networkLocation\$64installer"
		Write-Host "Using the 64 bit Installer to Install Puppet on $_"
		$script:installer = "$destdir\$64installer"
		}
	else {
		$script:path = "$networkLocation\$32installer"
		Write-Host "Using the 32 bit Installer to Install Puppet on $_"
		$script:installer = "$destdir\$32installer"
		}

if (!(Test-Path -path $destinationFolder))
	{
		Write-Host "Creating Local Directory for the $installer installer on $_"
		New-Item $destinationFolder -Type Directory
	}
		Copy-Item -Path $script:path -Destination $destinationFolder
		Write-Host "Installing Puppet on $_"
		invoke-command -computername $_ -scriptblock $scriptBlockContent -ArgumentList $script:installer,$service_user,$pw,$puppetMaster,$domain
		Write-Host "Done installing Puppet on $_, now killing any lingering MSIEXEC processes"
		invoke-command -computername $_ -scriptblock {Stop-Process -name msiexec -Force}

		}

	See-PuppetInstalled
}
