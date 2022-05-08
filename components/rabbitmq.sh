#!/usr/bin/env bash

source common.sh

CheckRootUser


ECHO "Setting up rabbitmq Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>> ${LOG_FILE}
StatusCheck $?

ECHO "Installing Rabbitmq & Erlang"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>> ${LOG_FILE}
StatusCheck $?

ECHO "Starting Rabbitmq service"
systemctl enable rabbitmq-server &>> ${LOG_FILE} && systemctl start rabbitmq-server &>> ${LOG_FILE}
StatusCheck $?

rabbitmqctl list_users | grep roboshop &>> ${LOG_FILE}

if [ $? -ne 0 ]
then
ECHO "Creating Application user"
rabbitmqctl add_user roboshop roboshop123 &>> ${LOG_FILE}
StatusCheck $?
fi

ECHO "Setting up Application user permissions"
rabbitmqctl set_user_tags roboshop administrator &>> ${LOG_FILE} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> ${LOG_FILE}
StatusCheck $?





