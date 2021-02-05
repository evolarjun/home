# home - basic setup for cloud VMs or other new machines

```
sudo apt-get install git
git clone https://github.com/evolarjun/home
git init .
git remote add -t \* -f origin https://github.com/evolarjun/home
git checkout master

Setup scripts
-------------
- `_apt-setup.sh` Runs apt-get install commands for new server
- `_setup.sh`     Runs installs for new home directory
