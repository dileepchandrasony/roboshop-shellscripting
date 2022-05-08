#!/usr/bin/env bash

component=$1

sshpass -f rootpwd.sh ssh -o StrictHostKeyChecking=no root@54.83.109.215

echo "Instance connected"

set-hostanme ${component}

git clone https://github.com/dileepchandrasony/roboshop-shellscripting.git

cd roboshop-shellscripting

make ${component}

