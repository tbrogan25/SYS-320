#!/bin/bash

if [ -e /home/timothy/git/SYS-320/'Week 2'/server.bash ]
then
  echo 'Do you want to run more code?'
  read user_response
  if [ $user_response == 'y' ]
  then
    echo "hi"
  fi
fi
