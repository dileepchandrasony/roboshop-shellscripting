#!/usr/bin/env bash

source common.sh
CheckRootUser

ECHO "Setting up Mongo Db Repo"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>> ${LOG_FILE}
StatusCheck $?

ECHO "Installing Mongo DB"
yum install -y mongodb-org &>> ${LOG_FILE}
StatusCheck $?

ECHO "Configure the listen address in Mongo DB Config file"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
StatusCheck $?

ECHO "Starting Mongo DB Service"
systemctl restart mongod &>> ${LOG_FILE} && systemctl enable mongod &>> ${LOG_FILE}
StatusCheck $?

ECHO "Downloading schema"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>> ${LOG_FILE}
StatusCheck $?

ECHO "Extracting zip file of schema"
cd /tmp && unzip -o mongodb.zip &>> ${LOG_FILE}

cd mongodb-main

ECHO "Loading Schema"
for component in catalogue users
do
  mongo < ${component}.js &>> ${LOG_FILE}
done
StatusCheck $?
