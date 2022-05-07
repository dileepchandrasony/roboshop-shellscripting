#!/usr/bin/env bash

source common.sh

CheckRootUser

ECHO "Setting up MySQL Repo"
curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>> ${LOG_FILE}
StatusCheck $?

ECHO "Installing MySQL Server"
yum install mysql-community-server -y &>> ${LOG_FILE}
StatusCheck $?


ECHO "Starting MySQL Server"
systemctl enable mysqld &>> ${LOG_FILE} && systemctl start mysqld &>> ${LOG_FILE}
StatusCheck $?


DEFAULT_PASSWORD=$(grep 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" > /tmp/root-pass.sql

echo show databases | mysql -uroot -pRoboShop@1 &>> ${LOG_FILE}
if [ $? -ne 0 ]
then
  ECHO "Reset MySQL password"
  mysql --connect-expired-password -u root -p${DEFAULT_PASSWORD} < /tmp/root-pass.sql &>> ${LOG_FILE}
  StatusCheck $?
fi

echo 'show plugins;' | mysql -uroot -pRoboShop@1 2>> ${LOG_FILE} | grep validate_password &>> ${LOG_FILE}
if [ $? -eq 0 ]
then
  ECHO "Uninstalling password validation plugin"
  echo "uninstall plugin validate_password;" |  mysql -uroot -pRoboShop@1 &>>${LOG_FILE}
  StatusCheck $?
fi

ECHO "Downloading schema"
cd /tmp
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>> ${LOG_FILE} && unzip -o /tmp/mysql.zip &>> ${LOG_FILE}
StatusCheck $?

ECHO "Loading Schema"
cd mysql-main
mysql -u root -pRoboShop@1 <shipping.sql &>> ${LOG_FILE}
StatusCheck $?



