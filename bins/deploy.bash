#!/bin/bash
# Author : Tech-Alchemist.Github.Io
# deploy.bash : Start/Stop the Deployment.

## Root Check ##
[[ "$(id -u)"  != "0" ]] && { echo "[-] Please Run From Root Access." ; exit 1 ;}

ops_dir="/opt/opsworks/deploy/bins"
logfile="/var/log/deploy/deploy.log"
cd $ops_dir

shopt -s expand_aliases
alias date="TZ='Asia/Kolkata' date"

## Argument Check ##
if [[ -z "$1" ]] ; then
echo -ne "\e[31m[-]\e[0m Usage=> # deploy.bash \e[32m<start/stop>\e[0m\n"
exit 1

elif [[ "$1" == "start" || "$1" == "stop" ]] ; then

for pis in `ps aux | grep "$0" |sed '/grep/d'| awk '{print $2}' | sed "/$$/d"` ; do
kill -9 $pis  && echo -ne "\e[36m[+]\e[0m Pid => $pis killed\n"; done 2> /dev/null
for pis in `ps aux | grep -i "git" |sed '/grep/d'| awk '{print $2}' | sed "/$$/d"` ; do
kill -9 $pis  && echo -ne "\e[36m[+]\e[0m Pid => $pis killed\n"; done 2> /dev/null
kill -9 `pgrep git` 2> /dev/null ; killall git 2> /dev/null

echo -ne "\e[36m[+]\e[0m Old Processes Killed"
[[ "$1" == "stop" ]] && {
echo -ne "\n\e[36m[+]\e[0m Deployment [\e[31mStopped\e[0m] on `date`\n"
kill -9 `pgrep deploy.bash` > /dev/null
exit 0
}

else
echo -ne "\e[31m[-]\e[0m Usage=> # deploy.bash \e[32m<start/stop>\e[0m\n"
exit 1

fi

wanip="`dig +short myip.opendns.com @resolver1.opendns.com`"
admin_email=""
timer="10"
webuser='examplewebuser'
src='examplesrc'

declare -A git
$src $ops_dir/../confs/main.conf

deploy_main()
{
for num in "${!git[@]}"
do
	branchpath=${git[$num]}
	branch="$(echo $branchpath | cut -d: -f1)"
	path="$(echo $branchpath | cut -d: -f2)"
	user="$(echo $branchpath | cut -d: -f3)"

	cd $path
	rm -f .git/*.lock
	while true ; do
		sleep $timer
		echo -e "\n\n[+] `date`: Deploying from [$branch] => ($path)\n"
		git reset --soft
                if [ "$auto_push" == "no" ] ; then
                        echo "[-] `date` : AutoPush Off"
                else
                        git add . && git commit -m "[+] AutoPush on `date` from $wanip($path) to [$branch]"
                        git push -u gitlab $branch || echo "[-] `date` : Failed to Push [$branch] from ($path)"
                fi
                git pull gitlab $branch > /tmp/deploy.$user.txt 2>&1|| {
			echo -ne "\n\n[-] `date` : Failed to Pull [$branch] => ($path)\n"
                	if [ "$admin_email" == "" ] ; then
                        	echo "[-] `date` : Email Alerts Are Off"
                	else
				echo -ne "\n Deployment Issue \n\n $wanip => $path [ $branch ~ $user ] \n `date`\n\n `cat /tmp/deploy.$user.txt` \n `git status`" | mail -s "Deployment Error $user:$path $wanip" "$admin_email"
                                sleep 60
			fi
		}

		## Comment the following if your all projects are deployed from root user, Just for Dev Modes ##
		if [[ $user != "root" ]] ; then
			find $path -user root -amin -10 -exec chown -R $user.$webuser {} \;
		fi

	done >> "$logfile" &

done
}

deploy_main  2>>  "$logfile"

echo "[+] `date` : DeployTool Started" >> "$logfile"
echo -ne "\n\e[36m[+]\e[0m Deployment [\e[32mStarted\e[0m] on `date` \n    LogFile => \e[35m$logfile\e[0m\n"

## Thats All Folks ##
