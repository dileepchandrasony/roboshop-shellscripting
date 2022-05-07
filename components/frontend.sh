#!/usr/bin/env bash

source common.sh

CheckRootUser

ECHO "Installing Nginx"
yum install nginx -y &>> ${LOG_FILE}
StatusCheck $?

#systemctl start nginx
echo -e "\n"

ECHO "Downloading frontend code"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>> ${LOG_FILE}
StatusCheck $?

cd /usr/share/nginx/html

echo -e "\n"

ECHO "Removing Old Files"
rm -rf * &>> ${LOG_FILE}
StatusCheck $?

echo -e "\n"

ECHO "Extracting Zip Content"
unzip /tmp/frontend.zip &>> ${LOG_FILE}
StatusCheck $?

echo -e "\n"

ECHO "Copying Extracted Content"
mv frontend-main/* . &>> ${LOG_FILE} && mv static/* . &>> ${LOG_FILE} && rm -rf frontend-main README.md &>> ${LOG_FILE}
StatusCheck $?

echo -e "\n"

ECHO "Copy Roboshop Nginx Config"
mv localhost.conf /etc/nginx/default.d/roboshop.conf &>> ${LOG_FILE}
StatusCheck $?

echo -e "\n"

ECHO "Updating Ngnix configuration"
for component in catalogue user cart shipping payment
do
  ECHO "Updating configuration for ${component}"
  sed -i -e "/${component}/ s/localhost/${component}.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
StatusCheck $?
done

echo -e "\n"

ECHO "Start Nginx Service"
systemctl enable nginx &>> ${LOG_FILE} && systemctl restart nginx &>> ${LOG_FILE}
StatusCheck $?
