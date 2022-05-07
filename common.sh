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

APPLICATION_SETUP() {
 id roboshop &>> ${LOG_FILE}
   if [ $? -ne 0 ]
   then
     ECHO "Adding application user roboshop"
     useradd roboshop &>> 4{LOG_FILE}
     StatusCheck $?
   fi

ECHO "Downloading application content"
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>> ${LOG_FILE}
StatusCheck $?

ECHO "Extracting application content"
cd /home/roboshop && rm -rf ${COMPONENT} &>> ${LOG_FILE} && unzip /tmp/${COMPONENT}.zip &>> ${LOG_FILE} && mv ${COMPONENT}-main ${COMPONENT} &>> ${LOG_FILE}
StatusCheck $?

}

SYSTEMD_SETUP() {
  chown roboshop:roboshop /home/roboshop/${COMPONENT} -R
ECHO "Updating SystemD file"
sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/CARTENDPOINT/cart.roboshop.internal/' -e 's/DBHOST/mysql.roboshop.internal/' -e 's/CARTHOST/cart.roboshop.internal/' -e 's/USERHOST/user.roboshop.internal/' -e 's/AMQPHOST/rabbitmq.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service
StatusCheck $?

ECHO "Setting up systemd service"
mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
systemctl daemon-reload &>> ${LOG_FILE} && systemctl start ${COMPONENT} &>> ${LOG_FILE} && systemctl enable ${COMPONENT} &>> ${LOG_FILE}
StatusCheck $?

}

NODEJS() {
  ECHO "Configuring NodeJS repos"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> ${LOG_FILE}
  StatusCheck $?

  ECHO "Installing  nodejs"
  yum install nodejs gcc-c++ -y &>> ${LOG_FILE}
  StatusCheck $?

  APPLICATION_SETUP

  ECHO "Installing user component"
  cd /home/roboshop/${COMPONENT} && npm install &>> ${LOG_FILE}
  StatusCheck $?

SYSTEMD_SETUP

}

JAVA() {

ECHO "Installing Java and Maven"
yum install maven -y &>> ${LOG_FILE}
StatusCheck $?

APPLICATION_SETUP

ECHO "Compiling maven package"
cd /home/roboshop/${COMPONENT} && mvn clean package &>> ${LOG_FILE} && mv target/${COMPONENT}-1.0.jar ${COMPONENT}.jar
StatusCheck $?

SYSTEMD_SETUP
}


PYTHON() {

ECHO "Installing Python"
yum install python36 gcc python3-devel -y &>>${LOG_FILE}
StatusCheck $?


APPLICATION_SETUP

ECHO "Installing python dependencies"
cd /home/roboshop/${COMPONENT} &>>${LOG_FILE} && pip3 install -r requirements.txt &>>${LOG_FILE}
StatusCheck $?


USER_ID=$(id -u roboshop)
GROUP_ID=$(id -g roboshop)

ECHO "Updating Roboshop configuration"
sed -i -e "/^uid/ c uid = ${USER_ID}" -e "/^gid/ c gid = ${GROUP_ID}" /home/roboshop/${COMPONENT}/${COMPONENT}.ini &>>${LOG_FILE}
StatusCheck $?

SYSTEMD_SETUP
}


GOLANG() {

ECHO "Installing golang"
yum install golang -y &>>${LOG_FILE}
StatusCheck $?


APPLICATION_SETUP

ECHO "Configuring GOLANG"
cd /home/roboshop/${COMPONENT} &>>${LOG_FILE} && go mod init dispatch &>>${LOG_FILE} && go get &>>${LOG_FILE} && go build &>>${LOG_FILE}
StatusCheck $?

SYSTEMD_SETUP
}