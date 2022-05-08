#!/usr/bin/env bash

component=$1

sshpass -f rootpwd.sh ssh -o StrictHostKeyChecking=no root@3.91.9.250

set-hostanme ${component}

git clone https://github.com/dileepchandrasony/roboshop-shellscripting.git

cd roboshop-shellscripting

make ${component}

