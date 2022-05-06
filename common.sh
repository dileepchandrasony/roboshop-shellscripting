#!/usr/bin/env bash

CheckRootUser() {
  USER_ID=$(id -u)

  if [ "$USER_ID" -ne "0" ]
  then
    echo -e "\e[31mYou should run this script as root user only\e[0m"
    exit 1
  fi
}

LOG_FILE=/tmp/roboshop.log
rm -f $LOG_FILE

StatusCheck() {
  if [ $1 -eq 0 ]
  then
    echo -e "\e[32mSUCCESSFUL\e[0m"
  else
    echo -e "\e[31mFAILED\e[0m"
    echo "Check the error log $LOG_FILE for more information "
    exit 1
  fi
}

ECHO() {
  echo -e "**************************************$1****************************************\n" >> $LOG_FILE
  echo "$1"
}


NODEJS() {
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
  curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>> ${LOG_FILE}
  StatusCheck $?

  ECHO "Extracting application content"
  cd /home/roboshop && rm -rf ${COMPONENT} &>> ${LOG_FILE} && unzip /tmp/${COMPONENT}.zip &>> ${LOG_FILE} && mv ${COMPONENT}-main ${COMPONENT} &>> ${LOG_FILE}
  StatusCheck $?

  ECHO "Installing NodeJS"
  cd /home/roboshop/${COMPONENT} && npm install &>> ${LOG_FILE} && chown roboshop:roboshop /home/roboshop/${COMPONENT} -R
  StatusCheck $?

  ECHO "Updating SystemD file"
  sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service
  StatusCheck $?

  ECHO "Setting up systemd service"
  mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
  systemctl daemon-reload &>> ${LOG_FILE} && systemctl start ${COMPONENT} &>> ${LOG_FILE} && systemctl enable ${COMPONENT} &>> ${LOG_FILE}
  StatusCheck $?

}