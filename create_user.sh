#!/bin/bash#set -x
echo -n "Enter name user: "read username
echo -n "Enter comment: "
read comment
echo -n "Enter password of server: "read -s password
echo -n "add in sudo? (yes/no): "
read sign_sudo
echo -n "all or commands or groups? (1/2/3): "read type_sudo
#set -x

if [ "$type_sudo" = "2" ]; then        echo -n "Enter commands for sudo: "
        read sudo_commelif [ "$type_sudo" = "3" ]; then
        echo -n "Enter commands or groups for sudo: "        read sudo_comm
fi
file=/home/dgolovkin/scripts/hosts

for host in $(cat $file); do        gossh="sshpass -p $password ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 root@$host"
        ping -c 2 $host > /dev/null 2>&1        if [ $? -eq 0 ]; then
                find_user=$($gossh "grep -i $username /etc/passwd")                if [ -n "$find_user" ]; then
                        echo "user $username already created on $host - $find_user"                else
                        $gossh "adduser -c '$comment' $username;echo -e 'Ch@ngeMeNow' | passwd $username --stdin; chage -d 0 $username"                        if [ "$sign_sudo" = "yes" ]; then
                                if [ "$type_sudo" = "1" ]; then                                        $gossh "echo '$username ALL=(ALL)       ALL' >> /etc/sudoers"
                                elif [ "$type_sudo" = "2" ]; then                                        $gossh "echo '$username ALL=(ALL)       $sudo_comm' >> /etc/sudoers"
                                elif [ "$type_sudo" = "3" ]; then                                        for comm in $(echo "$sudo_comm" | tr ',' ' '); do
                                                echo $comm                                                if [[ -n $($gossh "grep 'Cmnd_Alias $comm' /etc/sudoers") ]]; then
                                                        $gossh "sed -i 's/^#\(.*\Cmnd_Alias $comm\)/\1/' /etc/sudoers"                                                        res_comm+=$comm,
                                                else                                                        echo "group $comm not found in sudoers file"
                                                fi                                        done
                                        $gossh "echo '$username  ALL=(ALL)       ${res_comm%,*}' >> /etc/sudoers"                                fi
                        fi                fi
        fidone