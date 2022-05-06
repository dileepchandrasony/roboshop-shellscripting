#!/usr/bin/env bash

source common.sh
CheckRootUser


ECHO "Configuring NodeJS repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${LOG_FILE}
StatusCheck $?

ECHO "Installing  nodejs"
yum install nodejs gcc-c++ -y &>> ${LOG_FILE}
StatusCheck $?

id roboshop &>> ${LOG_FILE}
if [ $? -ne 0 ]
then
  ECHO "Adding application user roboshop"
  useradd roboshop &>> 4{LOG_FILE}
  StatusCheck $?
fi

ECHO "Downloading application content"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>> ${LOG_FILE}
StatusCheck $?

ECHO "Extracting application content"
cd /home/roboshop && rm -rf catalogue &>> ${LOG_FILE} && unzip /tmp/catalogue.zip &>> ${LOG_FILE} && mv catalogue-main catalogue &>> ${LOG_FILE}
StatusCheck $?

ECHO "Installing NodeJS"
cd /home/roboshop/catalogue && npm install &>> ${LOG_FILE} && chown roboshop:roboshop /home/roboshop/catalogue -R
StatusCheck $?

ECHO "Updating SystemD file"
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/catalogue/systemd.service
StatusCheck $?

ECHO "Setting up systemd service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service
systemctl daemon-reload &>> ${LOG_FILE} && systemctl start catalogue &>> ${LOG_FILE} && systemctl enable catalogue &>> ${LOG_FILE}
StatusCheck $?

