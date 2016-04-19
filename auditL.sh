#!/bin/bash
#A script to audit local linux
v="version 0.6"
#@oshearing

#help function
usage () 
{ 
echo -e "\n\e[00;31m#########################################################\e[00m" 
echo -e "\e[00;31m#\e[00m" "\e[00;33mLocal Audit Linux Script\e[00m" "\e[00;31m#\e[00m"
echo -e "\e[00;31m#########################################################\e[00m"
echo -e "\e[00;33m# $v\e[00m\n"
echo -e "\e[00;33m# Example: ./auditL.sh -r report \e[00m\n"

		echo "OPTIONS:"
		echo "-r	Enter report name" 
		echo "-h	Displays this help text"
		echo -e "\n"
		echo "Running with no options = limited scans/no output file"
		
echo -e "\e[00;31m#########################################################\e[00m"		
}
while getopts "h:k:r:e:t" option; do
 case "${option}" in
	  r) report=${OPTARG}"_"`date +"%d-%m-%y"`;;
	  e) export=${OPTARG};;
	  h) usage; exit;;
	  *) usage; exit;;
 esac
done

echo -e "\n\e[00;31m#########################################################\e[00m"  |tee -a $report 2>/dev/null
echo -e "\e[00;31m#\e[00m" "\e[00;33mLocal Audit Linux Script\e[00m" "\e[00;31m#\e[00m" |tee -a $report 2>/dev/null
echo -e "\e[00;31m#########################################################\e[00m" |tee -a $report 2>/dev/null
echo -e "\e[00;33m# $v\e[00m\n" |tee -a $report 2>/dev/null
echo -e "\e[00;33m# Example: ./auditL.sh -r report \e[00m\n" |tee -a $report 2>/dev/null

if [ "$report" ]; then 
	echo "report name = $report" |tee -a $report 2>/dev/null
else 
	:
fi

who=`whoami` |tee -a $report 2>/dev/null
echo -e "\n" |tee -a $report 2>/dev/null

echo -e "\e[00;33mScan started at:"; date |tee -a $report 2>/dev/null
echo -e "\e[00m\n" |tee -a $report 2>/dev/null

echo -e "\e[00;33m### SYSTEM ##############################################\e[00m" |tee -a $report 2>/dev/null

#basic kernel info
unameinfo=`uname -a 2>/dev/null`
if [ "$unameinfo" ]; then
  echo -e "\e[00;31mKernel information:\e[00m\n$unameinfo" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

procver=`cat /proc/version 2>/dev/null`
if [ "$procver" ]; then
  echo -e "\e[00;31mKernel information (continued):\e[00m\n$procver" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#search all *-release files for version info
release=`cat /etc/*-release 2>/dev/null`
if [ "$release" ]; then
  echo -e "\e[00;31mSpecific release information:\e[00m\n$release" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#target hostname info
hostnamed=`hostname 2>/dev/null`
if [ "$hostnamed" ]; then
  echo -e "\e[00;31mHostname:\e[00m\n$hostnamed" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### USER/GROUP ##########################################\e[00m" |tee -a $report 2>/dev/null

#current user details
currusr=`id 2>/dev/null`
if [ "$currusr" ]; then
  echo -e "\e[00;31mCurrent user/group info:\e[00m\n$currusr" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#last logged on user information
lastlogedonusrs=`lastlog |grep -v "Never" 2>/dev/null`
if [ "$lastlogedonusrs" ]; then
  echo -e "\e[00;31mUsers that have previously logged onto the system:\e[00m\n$lastlogedonusrs" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#strips out username uid and gid values from /etc/passwd
usrsinfo=`cat /etc/passwd | cut -d ":" -f 1,2,3,4 2>/dev/null`
if [ "$usrsinfo" ]; then
  echo -e "\e[00;31mAll users and uid/gid info:\e[00m\n$usrsinfo" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#lists all id's and respective group(s)
grpinfo=`for i in $(cat /etc/passwd 2>/dev/null| cut -d":" -f1 2>/dev/null);do id $i;done 2>/dev/null`
if [ "$grpinfo" ]; then
  echo -e "\e[00;31mGroup memberships:\e[00m\n$grpinfo" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#checks to see if any hashes are stored in /etc/passwd (depreciated  *nix storage method)
hashesinpasswd=`grep -v '^[^:]*:[x]' /etc/passwd 2>/dev/null`
if [ "$hashesinpasswd" ]; then
  echo -e "\e[00;33mIt looks like we have password hashes in /etc/passwd!\e[00m\n$hashesinpasswd" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi
 
#locate custom user accounts with some 'known default' uids
#readpasswd=`grep -v "^#" /etc/passwd | awk -F: '$3 == 0 || $3 == 500 || $3 == 501 || $3 == 502 || $3 == 1000 || $3 == 1001 || $3 == 1002 || $3 == 2000 || $3 == 2001 || $3 == 2002 { print }'`
readpasswd=`grep -v "^#" /etc/passwd | awk -F: '$3 == 0 || $3 ~ /50[0-9]/ || $3 ~ /100[0-9]/ || $3 ~ /200[0-9]/ { print }'`
if [ "$readpasswd" ]; then
  echo -e "\e[00;31mSample entires from /etc/passwd (searching for uid values 0, 50?, 100?, 200?):\e[00m\n$readpasswd" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#checks to see if the shadow file can be read
readshadow=`cat /etc/shadow 2>/dev/null`
if [ "$readshadow" ]; then
  echo -e "\e[00;33m***We can read the shadow file!\e[00m\n$readshadow" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#checks to see if /etc/master.passwd can be read - BSD 'shadow' variant
readmasterpasswd=`cat /etc/master.passwd 2>/dev/null`
if [ "$readmasterpasswd" ]; then
  echo -e "\e[00;33m***We can read the master.passwd file!\e[00m\n$readmasterpasswd" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#all root accounts (uid 0)
echo -e "\e[00;31mSuper user account(s):\e[00m" | tee -a $report 2>/dev/null; grep -v -E "^#" /etc/passwd 2>/dev/null| awk -F: '$3 == 0 { print $1}' 2>/dev/null |tee -a $report 2>/dev/null
echo -e "\n" |tee -a $report 2>/dev/null

#pull out vital sudoers info
sudoers=`cat /etc/sudoers 2>/dev/null | grep -v -e '^$'|grep -v "#"`
if [ "$sudoers" ]; then
  echo -e "\e[00;31mSudoers configuration (condensed):\e[00m$sudoers" | tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#can we sudo without supplying a password
sudoperms=`echo '' | sudo -S -l 2>/dev/null`
if [ "$sudoperms" ]; then
  echo -e "\e[00;33mWe can sudo without supplying a password!\e[00m\n$sudoperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#known 'good' breakout binaries
sudopwnage=`echo '' | sudo -S -l 2>/dev/null | grep -w 'nmap\|perl\|'awk'\|'find'\|'bash'\|'sh'\|'man'\|'more'\|'less'\|'vi'\|'vim'\|'nc'\|'netcat'\|python\|ruby\|lua\|irb' | xargs -r ls -la 2>/dev/null`
if [ "$sudopwnage" ]; then
  echo -e "\e[00;33m***Possible Sudo PWNAGE!\e[00m\n$sudopwnage" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#checks to see if roots home directory is accessible
rthmdir=`ls -ahl /root/ 2>/dev/null`
if [ "$rthmdir" ]; then
  echo -e "\e[00;33m***We can read root's home directory!\e[00m\n$rthmdir" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#displays /home directory permissions - check if any are lax
homedirperms=`ls -ahl /home/ 2>/dev/null`
if [ "$homedirperms" ]; then
  echo -e "\e[00;31mAre permissions on /home directories lax:\e[00m\n$homedirperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#looks for world-reabable files within /home - depending on number of /home dirs & files, this can take some time so is only 'activated' with thorough scanning switch
#wrfileshm=`find /home/ -perm -4 -type f -exec ls -al {} \; 2>/dev/null`
#if [ "$wrfileshm" ]; then
#	echo -e "\e[00;31mWorld-readable files within /home:\e[00m\n$wrfileshm" |tee -a $report 2>/dev/null
#	echo -e "\n" |tee -a $report 2>/dev/null
#else 
#	:
#fi

#checks for if various ssh files are accessible - this can take some time so is only 'activated' with thorough scanning switch
sshfiles=`find / -name "id_dsa*" -o -name "id_rsa*" -o -name "known_hosts" -o -name "authorized_hosts" -o -name "authorized_keys" 2>/dev/null |xargs -r ls`
if [ "$sshfiles" ]; then
	echo -e "\e[00;31mSSH keys/host information found in the following locations:\e[00m\n$sshfiles" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#is root permitted to login via ssh
sshrootlogin=`grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" | awk '{print  $2}'`
if [ "$sshrootlogin" = "yes" ]; then
  echo -e "\e[00;31mRoot is allowed to login via SSH:\e[00m" |tee -a $report 2>/dev/null; grep "PermitRootLogin " /etc/ssh/sshd_config 2>/dev/null | grep -v "#" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### ENVIRONMENTAL #######################################\e[00m" |tee -a $report 2>/dev/null

#current path configuration
pathinfo=`echo $PATH 2>/dev/null`
if [ "$pathinfo" ]; then
  echo -e "\e[00;31mPath information:\e[00m\n$pathinfo" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#current umask value with both octal and symbolic output
umask=`umask -S 2>/dev/null & umask 2>/dev/null`
if [ "$umask" ]; then
  echo -e "\e[00;31mCurrent umask value:\e[00m\n$umask" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#umask value as in /etc/login.defs
umaskdef=`cat /etc/login.defs 2>/dev/null |grep -i UMASK 2>/dev/null |grep -v "#" 2>/dev/null`
if [ "$umaskdef" ]; then
  echo -e "\e[00;31mumask value as specified in /etc/login.defs:\e[00m\n$umaskdef" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#password policy information as stored in /etc/login.defs
logindefs=`cat /etc/login.defs 2>/dev/null | grep "PASS_MAX_DAYS\|PASS_MIN_DAYS\|PASS_WARN_AGE\|ENCRYPT_METHOD" 2>/dev/null | grep -v "#" 2>/dev/null`
if [ "$logindefs" ]; then
  echo -e "\e[00;31mPassword and storage information:\e[00m\n$logindefs" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### JOBS/TASKS ##########################################\e[00m" |tee -a $report 2>/dev/null

#are there any cron jobs configured
cronjobs=`ls -la /etc/cron* 2>/dev/null`
if [ "$cronjobs" ]; then
  echo -e "\e[00;31mCron jobs:\e[00m\n$cronjobs" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#can we manipulate these jobs in any way
cronjobwwperms=`find /etc/cron* -perm -0002 -exec ls -la {} \; -exec cat {} 2>/dev/null \;`
if [ "$cronjobwwperms" ]; then
  echo -e "\e[00;33m***World-writable cron jobs and file contents:\e[00m\n$cronjobwwperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#contab contents
crontab=`cat /etc/crontab 2>/dev/null`
if [ "$crontab" ]; then
  echo -e "\e[00;31mCrontab contents:\e[00m\n$crontab" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

crontabvar=`ls -la /var/spool/cron/crontabs 2>/dev/null`
if [ "$crontabvar" ]; then
  echo -e "\e[00;31mAnything interesting in /var/spool/cron/crontabs:\e[00m\n$crontabvar" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

anacronjobs=`ls -la /etc/anacrontab 2>/dev/null; cat /etc/anacrontab 2>/dev/null`
if [ "$anacronjobs" ]; then
  echo -e "\e[00;31mAnacron jobs and associated file permissions:\e[00m\n$anacronjobs" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

anacrontab=`ls -la /var/spool/anacron 2>/dev/null`
if [ "$anacrontab" ]; then
  echo -e "\e[00;31mWhen were jobs last executed (/var/spool/anacron contents):\e[00m\n$anacrontab" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#pull out account names from /etc/passwd and see if any users have associated cronjobs (priv command)
cronother=`cat /etc/passwd | cut -d ":" -f 1 | xargs -n1 crontab -l -u 2>/dev/null`
if [ "$cronother" ]; then
  echo -e "\e[00;31mJobs held by all users:\e[00m\n$cronother" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### NETWORKING  ##########################################\e[00m" |tee -a $report 2>/dev/null

#nic information
nicinfo=`/sbin/ifconfig -a 2>/dev/null`
if [ "$nicinfo" ]; then
  echo -e "\e[00;31mNetwork & IP info:\e[00m\n$nicinfo" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#dns settings
nsinfo=`cat /etc/resolv.conf 2>/dev/null | grep "nameserver"`
if [ "$nsinfo" ]; then
  echo -e "\e[00;31mNameserver(s):\e[00m\n$nsinfo" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#default route configuration
defroute=`route 2>/dev/null | grep default`
if [ "$defroute" ]; then
  echo -e "\e[00;31mDefault route:\e[00m\n$defroute" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#listening TCP
tcpservs=`netstat -antp 2>/dev/null`
if [ "$tcpservs" ]; then
  echo -e "\e[00;31mListening TCP:\e[00m\n$tcpservs" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#listening UDP
udpservs=`netstat -anup 2>/dev/null`
if [ "$udpservs" ]; then
  echo -e "\e[00;31mListening UDP:\e[00m\n$udpservs" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### SERVICES #############################################\e[00m" |tee -a $report 2>/dev/null

#running processes
psaux=`ps aux 2>/dev/null`
if [ "$psaux" ]; then
  echo -e "\e[00;31mRunning processes:\e[00m\n$psaux" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#lookup process binary path and permissisons
procperm=`ps aux | awk '{print $11}'|xargs -r ls -la 2>/dev/null |awk '!x[$0]++'`
if [ "$procperm" ]; then
  echo -e "\e[00;31mProcess binaries & associated permissions (from above list):\e[00m\n$procperm" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#anything 'useful' in inetd.conf
inetdread=`cat /etc/inetd.conf 2>/dev/null`
if [ "$inetdread" ]; then
  echo -e "\e[00;31mContents of /etc/inetd.conf:\e[00m\n$inetdread" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#very 'rough' command to extract associated binaries from inetd.conf & show permisisons of each
inetdbinperms=`cat /etc/inetd.conf 2>/dev/null | awk '{print $7}' |xargs -r ls -la 2>/dev/null`
if [ "$inetdbinperms" ]; then
  echo -e "\e[00;31mThe related inetd binary permissions:\e[00m\n$inetdbinperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

xinetdread=`cat /etc/xinetd.conf 2>/dev/null`
if [ "$xinetdread" ]; then
  echo -e "\e[00;31mContents of /etc/xinetd.conf:\e[00m\n$xinetdread" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

xinetdincd=`cat /etc/xinetd.conf 2>/dev/null |grep "/etc/xinetd.d" 2>/dev/null`
if [ "$xinetdincd" ]; then
  echo -e "\e[00;31m/etc/xinetd.d is included in /etc/xinetd.conf - associated binary permissions are listed below:\e[00m" ls -la /etc/xinetd.d 2>/dev/null |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#very 'rough' command to extract associated binaries from xinetd.conf & show permisisons of each
xinetdbinperms=`cat /etc/xinetd.conf 2>/dev/null | awk '{print $7}' |xargs -r ls -la 2>/dev/null`
if [ "$xinetdbinperms" ]; then
  echo -e "\e[00;31mThe related xinetd binary permissions:\e[00m\n$xinetdbinperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

initdread=`ls -la /etc/init.d 2>/dev/null`
if [ "$initdread" ]; then
  echo -e "\e[00;31m/etc/init.d/ binary permissions:\e[00m\n$initdread" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi  

#init.d files NOT belonging to root!
initdperms=`find /etc/init.d/ \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$initdperms" ]; then
  echo -e "\e[00;31m/etc/init.d/ files not belonging to root (uid 0):\e[00m\n$initdperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

rcdread=`ls -la /etc/rc.d/init.d 2>/dev/null`
if [ "$rcdread" ]; then
  echo -e "\e[00;31m/etc/rc.d/init.d binary permissions:\e[00m\n$rcdread" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#init.d files NOT belonging to root!
rcdperms=`find /etc/rc.d/init.d \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$rcdperms" ]; then
  echo -e "\e[00;31m/etc/rc.d/init.d files not belonging to root (uid 0):\e[00m\n$rcdperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

usrrcdread=`ls -la /usr/local/etc/rc.d 2>/dev/null`
if [ "$usrrcdread" ]; then
  echo -e "\e[00;31m/usr/local/etc/rc.d binary permissions:\e[00m\n$usrrcdread" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#rc.d files NOT belonging to root!
usrrcdperms=`find /usr/local/etc/rc.d \! -uid 0 -type f 2>/dev/null |xargs -r ls -la 2>/dev/null`
if [ "$usrrcdperms" ]; then
  echo -e "\e[00;31m/usr/local/etc/rc.d files not belonging to root (uid 0):\e[00m\n$usrrcdperms" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### SOFTWARE #############################################\e[00m" |tee -a $report 2>/dev/null

#sudo version - check to see if there are any known vulnerabilities with this
sudover=`sudo -V 2>/dev/null| grep "Sudo version" 2>/dev/null`
if [ "$sudover" ]; then
  echo -e "\e[00;31mSudo version:\e[00m\n$sudover" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#mysql details - if installed
mysqlver=`mysql --version 2>/dev/null`
if [ "$mysqlver" ]; then
  echo -e "\e[00;31mMYSQL version:\e[00m\n$mysqlver" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#checks to see if root/root will get us a connection
mysqlconnect=`mysqladmin -uroot -proot version 2>/dev/null`
if [ "$mysqlconnect" ]; then
  echo -e "\e[00;33m***We can connect to the local MYSQL service with default root/root credentials!\e[00m\n$mysqlconnect" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#mysql version details
mysqlconnectnopass=`mysqladmin -uroot version 2>/dev/null`
if [ "$mysqlconnectnopass" ]; then
  echo -e "\e[00;33m***We can connect to the local MYSQL service as 'root' and without a password!\e[00m\n$mysqlconnectnopass" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#postgres details - if installed
postgver=`psql -V 2>/dev/null`
if [ "$postgver" ]; then
  echo -e "\e[00;31mPostgres version:\e[00m\n$postgver" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#checks to see if any postgres password exists and connects to DB 'template0' - following commands are a variant on this
postcon1=`psql -U postgres template0 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon1" ]; then
  echo -e "\e[00;33m***We can connect to Postgres DB 'template0' as user 'postgres' with no password!:\e[00m\n$postcon1" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

postcon11=`psql -U postgres template1 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon11" ]; then
  echo -e "\e[00;33m***We can connect to Postgres DB 'template1' as user 'postgres' with no password!:\e[00m\n$postcon11" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

postcon2=`psql -U pgsql template0 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon2" ]; then
  echo -e "\e[00;33m***We can connect to Postgres DB 'template0' as user 'psql' with no password!:\e[00m\n$postcon2" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

postcon22=`psql -U pgsql template1 -c 'select version()' 2>/dev/null | grep version`
if [ "$postcon22" ]; then
  echo -e "\e[00;33m***We can connect to Postgres DB 'template1' as user 'psql' with no password!:\e[00m\n$postcon22" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#apache details - if installed
apachever=`apache2 -v 2>/dev/null; httpd -v 2>/dev/null`
if [ "$apachever" ]; then
  echo -e "\e[00;31mApache version:\e[00m\n$apachever" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#what account is apache running under
apacheusr=`cat /etc/apache2/envvars 2>/dev/null |grep -i 'user\|group' |awk '{sub(/.*\export /,"")}1'`
if [ "$apacheusr" ]; then
  echo -e "\e[00;31mApache user configuration:\e[00m\n$apacheusr" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### INTERESTING FILES ####################################\e[00m" |tee -a $report 2>/dev/null

#limited search for installed compilers
compiler=`dpkg --list 2>/dev/null| grep compiler |grep -v decompiler 2>/dev/null && yum list installed 'gcc*' 2>/dev/null| grep gcc 2>/dev/null`
if [ "$compiler" ]; then
  echo -e "\e[00;31mInstalled compilers:\e[00m\n$compiler" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
 else 
  :
fi

#manual check - lists out sensitive files, can we read/modify etc.
echo -e "\e[00;31mCan we read/write sensitive files:\e[00m" |tee -a $report 2>/dev/null; ls -la /etc/passwd 2>/dev/null |tee -a $report 2>/dev/null; ls -la /etc/group 2>/dev/null |tee -a $report 2>/dev/null; ls -la /etc/profile 2>/dev/null; ls -la /etc/shadow 2>/dev/null |tee -a $report 2>/dev/null; ls -la /etc/master.passwd 2>/dev/null |tee -a $report 2>/dev/null
echo -e "\n" |tee -a $report 2>/dev/null

#search for suid files - this can take some time so is only 'activated' with thorough scanning switch (as are all suid scans below)
findsuid=`find / -perm -4000 -type f 2>/dev/null`
if [ "$findsuid" ]; then
	echo -e "\e[00;31mSUID files:\e[00m\n$findsuid" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#list of 'interesting' suid files - feel free to make additions
intsuid=`find / -perm -4000 -type f 2>/dev/null | grep -w 'nmap\|perl\|'awk'\|'find'\|'bash'\|'sh'\|'man'\|'more'\|'less'\|'vi'\|'vim'\|'nc'\|'netcat'\|python\|ruby\|lua\|irb\|pl' | xargs -r ls -la` 2>/dev/null
if [ "$intsuid" ]; then
	echo -e "\e[00;33m***Possibly interesting SUID files:\e[00m\n$intsuid" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#lists word-writable suid files
wwsuid=`find / -perm -4007 -type f 2>/dev/null`
if [ "$wwsuid" ]; then
	echo -e "\e[00;31mWorld-writable SUID files:\e[00m\n$wwsuid" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#lists world-writable suid files owned by root
wwsuidrt=`find / -uid 0 -perm -4007 -type f 2>/dev/null`
if [ "$wwsuidrt" ]; then
	echo -e "\e[00;31mWorld-writable SUID files owned by root:\e[00m\n$wwsuidrt" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#search for guid files - this can take some time so is only 'activated' with thorough scanning switch (as are all guid scans below)
findguid=`find / -perm -2000 -type f 2>/dev/null`
if [ "$findguid" ]; then
	echo -e "\e[00;31mGUID files:\e[00m\n$findguid" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#list of 'interesting' guid files - feel free to make additions
intguid=`find / -perm -2000 -type f 2>/dev/null | grep -w 'nmap\|perl\|'awk'\|'find'\|'bash'\|'sh'\|'man'\|'more'\|'less'\|'vi'\|'vim'\|'nc'\|'netcat'\|python\|ruby\|lua\|irb\|pl' | xargs -r ls -la`
if [ "$intguid" ]; then
	echo -e "\e[00;33m***Possibly interesting GUID files:\e[00m\n$intguid" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#lists world-writable guid files
wwguid=`find / -perm -2007 -type f 2>/dev/null`
if [ "$wwguid" ]; then
	echo -e "\e[00;31mWorld-writable GUID files:\e[00m\n$wwguid" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#lists world-writable guid files owned by root
wwguidrt=`find / -uid 0 -perm -2007 -type f 2>/dev/null`
if [ "$wwguidrt" ]; then
	echo -e "\e[00;31mAWorld-writable GUID files owned by root:\e[00m\n$wwguidrt" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#list all world-writable files excluding /proc
wwfiles=`find / ! -path "*/proc/*" -perm -2 -type f -print 2>/dev/null`
if [ "$wwfiles" ]; then
	echo -e "\e[00;31mWorld-writable files (excluding /proc):\e[00m\n$wwfiles" |tee -a $report 2>/dev/null
	echo -e "\n" |tee -a $report 2>/dev/null
else 
	:
fi

#are any .plan files accessible in /home (could contain useful information)
usrplan=`find /home -iname *.plan -exec ls -la {} \; -exec cat {} 2>/dev/null \;`
if [ "$usrplan" ]; then
  echo -e "\e[00;31mPlan file permissions and contents:\e[00m\n$usrplan" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

bsdusrplan=`find /usr/home -iname *.plan -exec ls -la {} \; -exec cat {} 2>/dev/null \;`
if [ "$bsdusrplan" ]; then
  echo -e "\e[00;31mPlan file permissions and contents:\e[00m\n$bsdusrplan" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#are there any .rhosts files accessible - these may allow us to login as another user etc.
rhostsusr=`find /home -iname *.rhosts -exec ls -la {} 2>/dev/null \; -exec cat {} 2>/dev/null \;`
if [ "$rhostsusr" ]; then
  echo -e "\e[00;31mrhost config file(s) and file contents:\e[00m\n$rhostsusr" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

bsdrhostsusr=`find /usr/home -iname *.rhosts -exec ls -la {} 2>/dev/null \; -exec cat {} 2>/dev/null \;`
if [ "$bsdrhostsusr" ]; then
  echo -e "\e[00;31mrhost config file(s) and file contents:\e[00m\n$bsdrhostsusr" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

rhostssys=`find /etc -iname hosts.equiv -exec ls -la {} 2>/dev/null \; -exec cat {} 2>/dev/null \;`
if [ "$rhostssys" ]; then
  echo -e "\e[00;31mHosts.equiv file details and file contents: \e[00m\n$rhostssys" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
  else 
  :
fi

#list nfs shares/permisisons etc.
nfsexports=`ls -la /etc/exports 2>/dev/null; cat /etc/exports 2>/dev/null`
if [ "$nfsexports" ]; then
  echo -e "\e[00;31mNFS config details: \e[00m\n$nfsexports" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
  else 
  :
fi

#looking for credentials in /etc/fstab
fstab=`cat /etc/fstab 2>/dev/null |grep username |awk '{sub(/.*\username=/,"");sub(/\,.*/,"")}1'| xargs -r echo username:; cat /etc/fstab 2>/dev/null |grep password |awk '{sub(/.*\password=/,"");sub(/\,.*/,"")}1'| xargs -r echo password:; cat /etc/fstab 2>/dev/null |grep domain |awk '{sub(/.*\domain=/,"");sub(/\,.*/,"")}1'| xargs -r echo domain:`
if [ "$fstab" ]; then
  echo -e "\e[00;33m***Looks like there are credentials in /etc/fstab!\e[00m\n$fstab" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
  else 
  :
fi

fstabcred=`cat /etc/fstab 2>/dev/null |grep cred |awk '{sub(/.*\credentials=/,"");sub(/\,.*/,"")}1'| xargs -I{} sh -c 'ls -la {}; cat {}'`
if [ "$fstabcred" ]; then
    echo -e "\e[00;33m***/etc/fstab contains a credentials file!\e[00m\n$fstabcred" |tee -a $report 2>/dev/null
    echo -e "\n" |tee -a $report 2>/dev/null
    else
    :
fi

#extract any user history files that are accessible
usrhist=`ls -la ~/.*_history 2>/dev/null`
if [ "$usrhist" ]; then
  echo -e "\e[00;31mCurrent user's history files:\e[00m\n$usrhist" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#can we read roots *_history files - could be passwords stored etc.
roothist=`ls -la /root/.*_history 2>/dev/null`
if [ "$roothist" ]; then
  echo -e "\e[00;33m***Root's history files are accessible!\e[00m\n$roothist" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#is there any mail accessible
readmail=`ls -la /var/mail 2>/dev/null`
if [ "$readmail" ]; then
  echo -e "\e[00;31mAny interesting mail in /var/mail:\e[00m\n$readmail" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

#can we read roots mail
readmailroot=`head /var/mail/root 2>/dev/null`
if [ "$readmailroot" ]; then
  echo -e "\e[00;33m***We can read /var/mail/root! (snippet below)\e[00m\n$readmailroot" |tee -a $report 2>/dev/null
  echo -e "\n" |tee -a $report 2>/dev/null
else 
  :
fi

echo -e "\e[00;33m### SCAN COMPLETE ####################################\e[00m" |tee -a $report 2>/dev/null

#EndOfScript
