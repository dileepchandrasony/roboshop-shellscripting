#!/usr/bin/env bash

source common.sh

component=$1

#ECHO "Connecting to Instance"

sshpass -f rootpwd.sh ssh -o StrictHostKeyChecking=no root@18.234.82.125

#StatusCheck $?

#ECHO "Setting up hostname"
set-hostname ${component}
#&>> ${LOG_FILE}
#StatusCheck $?


#ECHO "Cloning git repo"
git clone https://github.com/dileepchandrasony/roboshop-shellscripting.git
#&>> ${LOG_FILE}
#StatusCheck $?

cd roboshop-shellscripting

make ${component}

#ECHO "logging out"
logout
#StatusCheck $?
