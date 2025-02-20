#!/bin/bash

running=0

while [ ${running} -eq 0 ]
do

  LS_PID=`ps -eaf | grep "lsconnect" | grep -v "grep" | head -1 | awk '{print $2}'`

  if [ -z ${LS_PID} ];then # exit no more instances running
    running=1
  else
    LS_PID=`ps -eaf | grep "lsconnect" | head -1 | awk '{print $2}'`

    if [ ${LS_PID} -gt 0 ];then
      echo "shutting down [ PID = ${LS_PID} ]"
      kill -9 ${LS_PID} # look at email could use a curl call here ....
    else
      running=1
    fi
  sleep 2
  fi
done

echo "shutdown complete"
