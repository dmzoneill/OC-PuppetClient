#!/bin/bash

####################################################################################################
# Config
####################################################################################################

CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

LOG="/root/puppet.log"
PASSWORD="tester"
EMAIL="david.m.oneill@intel.com"
USEPROXY=1
PROXY="cache"
SEARCH="ir.intel.com"
PROXYFQDN="$PROXY.$SEARCH"
PROXYPORT="911"
HOSTNAME=`hostname -f`

####################################################################################################
# Reboot
####################################################################################################

function Reboot
{
	LogSection "Reboot"
	LogLine "Rebooting"
	reboot
}

####################################################################################################
# Log line
####################################################################################################

function LogLine
{
	echo "$1..." >> $LOG 2>&1
}

####################################################################################################
# Logsection header
####################################################################################################

function LogSection
{
	echo "$1..."
	LogLine "$1"
	LogLine "######################################################################################"
}

####################################################################################################
# Enable Service 
####################################################################################################

function EnableService
{
	LogLine "> ENABLESERVICE: $1"
	update-rc.d $1 defaults >> $LOG 2>&1
	sleep 1
}

####################################################################################################
# Remove Service 
####################################################################################################

function RemoveService
{
	LogLine "> REMOVESERVICE: $1"
	update-rc.d -f $1 remove >> $LOG 2>&1
	sleep 1
}

####################################################################################################
# Restart Service 
####################################################################################################

function RestartService
{
	LogLine "> RESTARTSERVICE: $1"
	echo "restart $1" >> $LOG 2>&1
	service $1 restart > /dev/null 2>&1
	/etc/init.d/$1 restart > /dev/null 2>&1
	sleep 3
}

####################################################################################################
# Stop Service 
####################################################################################################

function StopService
{
	LogLine "> STOPSERVICE: $1"
	service $1 status > /dev/null 2>&1
	
	if [[ $? -eq 0 ]]; then
		service $1 stop >> $LOG 2>&1
		sleep 2
	else
		if [ -f /etc/init.d/$1 ]; then
			/etc/init.d/$1 stop >> $LOG 2>&1
			sleep 2
		fi
	fi
}

####################################################################################################
# Install package
####################################################################################################

function InstallPackage
{
	LogLine "> INSTALLPACKAGE: $1"
	DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated --force-yes install $1 >> $LOG 2>&1
	sleep 1
}

####################################################################################################
# Install local package
####################################################################################################

function InstallLocalPackage
{
	LogLine "> INSTALLLOCALPACKAGE: $1"
	dpkg -i $1 >> $LOG 2>&1
	sleep 1
}

####################################################################################################
# ReInstall package
####################################################################################################

function ReinstallPackage
{
	LogLine "> REINSTALLPACKAGE: $1"
	DEBIAN_FRONTEND=noninteractive apt-get -y --allow-unauthenticated --force-yes install --reinstall $1 >> $LOG 2>&1
	sleep 1
}

####################################################################################################
# Remove package
####################################################################################################

function RemovePackage
{
	LogLine "> REMOVEPACKAGE: $1"
	apt-get -y remove $1 >> $LOG 2>&1
	sleep 1
}

####################################################################################################
# Remove package
####################################################################################################

function AutoRemovePackages
{
	LogLine "> REMOVEPACKAGE: $1"
	apt-get -y autoremove >> $LOG 2>&1
	sleep 1
}

####################################################################################################
# Update packages
####################################################################################################

function UpdatePackages
{
	LogLine "> UPDATEPACKAGES"
	apt-get clean all >> $LOG 2>&1
	apt-get -y update >> $LOG 2>&1
	apt-get -y upgrade >> $LOG 2>&1
	apt-get -y dist-upgrade >> $LOG 2>&1
	
	sleep 1
}

####################################################################################################
# Configure Proxy
####################################################################################################

function EnableProxy
{
	if [[ $USEPROXY -eq 1 ]]; then
		WriteConfig "/root/.wgetrc" "http_proxy=http://$PROXYFQDN:$PROXYPORT\nhttps_proxy=http://$PROXYFQDN:$PROXYPORT"
		WriteConfig "/etc/apt/apt.conf" "Acquire::http::Proxy \"http://$PROXYFQDN:$PROXYPORT/\";\nAcquire::https::Proxy \"http://$PROXYFQDN:$PROXYPORT/\";"		
	fi	

	proxyhost=""

	if [[ $USEPROXYHOSTS -eq 1 ]]; then
		proxyhost="$PROXYIP $PROXYFQDN $PROXY"
	fi
}

####################################################################################################
# Read Config Template
####################################################################################################

function ReadConfig
{
	LogLine "> READCONFIG: $1"
	IN=""

	while read LINE; do
		if [[ "$LINE" =~ ^\# || ! "$LINE" =~ \$ ]]; then
			CONTENT="$LINE"
		else
			CONTENT=$(eval echo "$LINE")
		fi
		IN=$(printf "%s%s" "$IN" "$CONTENT\n")
	done < $1

	echo "$IN"
}

####################################################################################################
# Write Config Template
####################################################################################################

function WriteConfig
{
	LogLine "> WRITECONFIG: $1"
	if [ ! -f "$1" ]; then
		touch "$1"
	fi

	echo -e "$2" > $1
}

####################################################################################################
# backup Config Template
####################################################################################################

function BackupConfig
{
	LogLine "> BACKUPCONFIG: $1"
	if [ ! -f "$1" ]; then
		touch "$1"
	else
		cp -v $1 $1.bak >> $LOG 2>&1
	fi
}

####################################################################################################
# Replace in config
####################################################################################################

function ReplaceInConfig
{
	LogLine "> REPLACEINCONFIG: $2 $3"
	echo -e "$1" | perl -lpe "s/$2/$3/g"
}

####################################################################################################
# Append to config
####################################################################################################

function AppendToConfig
{
	LogLine "> APPENDTOCONFIG: $1 $2"
	echo -e "$2" >> $1
}

####################################################################################################
# Download file
####################################################################################################

function DownloadFile
{
	LogLine "> DOWNLOADFILE: $1"
	wget $1 >> $LOG 2>&1	
}

####################################################################################################
# Copy File
####################################################################################################

function Copy
{
	cp -rv $1 $2 >> $LOG 2>&1
}

####################################################################################################
# Sql Exec
####################################################################################################

function SqlExec
{
	LogLine "> EXECSQL: $1"
	echo "$1" | mysql -u root -p$PASSWORD
}

####################################################################################################
# Pause 
####################################################################################################

function pause()
{
	read -p "Press [Enter] key to continue..."
}

####################################################################################################
# Main
####################################################################################################

function Main
{
	LogSection "System Preparation and Repository Configuration"
	RemovePackage "ufw"
	EnableProxy
	DownloadFile "http://apt.puppetlabs.com/puppetlabs-release-saucy.deb"
	InstallLocalPackage "puppetlabs-release-saucy.deb"
	UpdatePackages
	
	InstallPackage "puppet facter hiera"
	rsync -rtv ./etc/puppet/ /etc/puppet/
	mkdir -vp /etc/facter/facts.d >> $LOG 2>&1
	mkdir -vp /etc/puppet/ssl/private_keys/ >> $LOG 2>&1
	mkdir -vp /etc/puppet/ssl/ca/signed/ >> $LOG 2>&1
	Copy "./etc/puppet/ssl/private_keys/puppetclient.intel.com" "/etc/puppet/ssl/private_keys/puppetclient.intel.com"
	Copy "./etc/puppet/ssl/certs/puppetclient.intel.com" "/etc/puppet/ssl/certs/puppetclient.intel.com"
	Copy "./etc/puppet/modules/ec-puppet-config-1_0/files/facternodes.pl" "/etc/facter/facts.d"
	puppet agent --verbose --debug --no-daemonize
	
	reboot
}

Main
