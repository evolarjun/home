# home - basic setup for cloud VMs or other new machines

Min 10 gig drive
```
sudo apt-get update
sudo apt-get -y install git
# git clone https://github.com/evolarjun/home
git init .
git remote add origin https://github.com/evolarjun/home
git fetch
git checkout main
. .bash_profile
sudo bin/_apt-setup.sh # optional
_setup.sh
```
Setup scripts
-------------
- `_apt-setup.sh` Runs apt-get install commands for new server
- `_setup.sh`     Runs installs for new home directory
