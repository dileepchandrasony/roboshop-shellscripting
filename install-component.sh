#!/usr/bin/env bash

source common.sh

component=$1

#ECHO "Connecting to Instance"

sshpass -f rootpwd.sh ssh -o StrictHostKeyChecking=no root@18.234.82.125

#StatusCheck $?

#ECHO "Setting up hostname"

sshpass -f rootpwd.sh ssh root@18.234.82.125 'set-hostname ${component}'
#&>> ${LOG_FILE}
#StatusCheck $?


#ECHO "Cloning git repo"
sshpass -f rootpwd.sh ssh root@18.234.82.125 'git clone https://github.com/dileepchandrasony/roboshop-shellscripting.git'

sshpass -f rootpwd.sh ssh root@18.234.82.125 'git pull'
#&>> ${LOG_FILE}
#StatusCheck $?

sshpass -f rootpwd.sh ssh root@18.234.82.125 'cd roboshop-shellscripting'

sshpass -f rootpwd.sh ssh root@18.234.82.125 'make ${component}'

#ECHO "logging out"
sshpass -f rootpwd.sh ssh root@18.234.82.125 'logout'
#StatusCheck $?
