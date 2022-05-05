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

echo "Instance $NAME created"

sleep 15

INSTANCE_ID=$(aws ec2 describe-spot-instance-requests --filters Name=tag:Name,Values=${NAME} Name=state,Values=active --output table | grep InstanceId | awk '{print $4}')

echo "Instance ID of $NAME is $INSTANCE_ID"

IP_ADDRESS=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --output table | grep PrivateIpAddress | head -n 1 | awk '{print $4}')

echo "IP ADDRESS of $NAME is $IP_ADDRESS"

sed -e "s/COMPONENT/$NAME/" -e "s/IP_ADDRESS/$IP_ADDRESS" dns.json > /tmp/dns.json

aws route53 change-resource-record-sets --hosted-zone-id Z015361910VBDS6TXDD5T --change-batch file:///tmp/dns.json &> /dev/null

echo "DNS record created for $NAME instance"