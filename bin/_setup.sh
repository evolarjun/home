#!/bin/sh

WD=`pwd`

cd ~
mkdir setup_tmp
cd setup_tmp
    git clone https://github.com/evolarjun/scripts
    cd scripts
        make install
        cd ../..
rm -rf setup_tmp
cd $WD


