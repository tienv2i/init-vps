#!/usr/bin/env bash
set +x

# $1 as username=huynhat, $2 as password=anhtien456, $3 as root_password=anhtien!23
[[ -z "$1" ]] && username="huynhat" || username="$1"
[[ -z "$2" ]] && password="anhtien456" || username="$2"
[[ -z "$3" ]] && root_password="anhtien!23" || root_password="$3"

# check admin group wether sudo or wheel
[[ -n $(getent group "sudo") ]] && group="sudo" || group="wheel"

# change root password
echo "root:$root_password" | chpasswd

# create admin user
[[ -z $(getent passwd $username) ]] && useradd -m -s /bin/bash -g $group
echo "$username:$password" | chpasswd # change admin password after created

