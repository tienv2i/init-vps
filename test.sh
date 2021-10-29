#!/bin/bash
echo $PWD
if [[ -f nginx.repo ]]
then
    echo "File exist"
else echo "File no exists"
fi