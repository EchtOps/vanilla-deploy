This tool auto pulls code from git origins after the specific interval, to keep the vanilla deployments up to date.


Installation
-
```
$ sudo su
# mkdir -p /opt/echtops ; cd /opt/echtops
# git clone https://github.com/tech-alchemist/vanilla-deploy.git vanilla-deploy
# cd vanilla-deploy
# vim setupvars.conf            ## Fill All The Fields ##
# bash install
```

Config
-
```
# vim /etc/vanilla-deploy.conf
```

Usage
-
```
# deploy.bash < start / stop >
```
> [[ LICENSE ]](https://raw.githubusercontent.com/echtops/vanilla-deploy/master/LICENSE)
