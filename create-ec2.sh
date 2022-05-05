#!/usr/bin/env bash

if [ -z "$1" ]
then
  echo "Instance name is not passed as an argument"
  exit 1
fi

NAME=$1

aws ec2 describe-spot-instance-requests --filters Name=tag:Name,Values=${NAME} Name=state,Values=active --output table | grep InstanceId &> /dev/null

if [ $? -eq 0 ]
then
  echo "Instance $NAME Already Exists"
  exit 0
fi

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" --output table | grep ImageId | awk '{print $4}')

aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}" --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=$NAME}]" "ResourceType=instance,Tags=[{Key=Name,Value=$NAME}]" &> /dev/null

