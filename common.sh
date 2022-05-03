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
  if [ $1 eq 0 ]
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