#!/usr/bin/env bash

source common.sh

component=$1

ECHO "Connecting to Instance"

sshpass -f rootpwd.sh ssh -o StrictHostKeyChecking=no root@54.83.109.215

StatusCheck $?

set-hostanme ${component}

git clone https://github.com/dileepchandrasony/roboshop-shellscripting.git

cd roboshop-shellscripting

make ${component}

