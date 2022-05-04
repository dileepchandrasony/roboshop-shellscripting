#!/usr/bin/env bash

if [ -z "$1" ]
then
  echo "Instance name is not passed as an argument"
  exit 1
fi

if [ "$1" == "list" ]
then
  