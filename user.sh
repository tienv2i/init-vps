#!/bin/bash
set -x #echo on

echo "root:anhtien!23" | chpasswd
if [[ $(getent group sudo) ]]
then
    useradd -m -s /bin/bash -g sudo huynhat
elif [[ $(getent group wheel) ]]
then
    useradd -m -s /bin/bash -g wheel huynhat
    echo "huynhat:anhtien456" | chpasswd huynhat
else
    echo  "not supported"
fi
