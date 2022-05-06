#!/usr/bin/env bash

source common.sh

CheckRootUser


ECHO "Configuring Redis from Repos"
curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>> ${LOG_FILE}
StatusCheck $?

ECHO "Install Redis"
yum install redis-6.2.7 -y &>> ${LOG_FILE}
StatusCheck $?

ECHO "Update Redis configuration"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>> ${LOG_FILE}
StatusCheck $?

ECHO "Start Redis Service"
systemctl enable redis &>> ${LOG_FILE} && systemctl start redis &>> ${LOG_FILE}
StatusCheck $?

