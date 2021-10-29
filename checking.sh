if [[ $(getent group sudo) ]]
then
    echo "Sudo"
elif [[ $(getent group wheel) ]]
then
    echo "Wheel"
else
    echo  "not supported"
fi