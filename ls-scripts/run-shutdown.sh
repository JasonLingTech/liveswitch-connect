#!/bin/bash

running=0

while [ ${running} -eq 0 ]
do

  ps -eaf | grep "lsconnect" | head -1 | awk '{print $2}' 1>/dev/null 2>&1
  running=$?
  if [ ${running} -gt 0 ];then
    # exit no more instances running
    echo "..... end"
    exit 1

  else
    LS_PID=`ps -eaf | grep "lsconnect" | head -1 | awk '{print $2}'`
    echo "shutting down [ PID = ${LS_PID} ]"

    # look at email could use a curl call here ....

    kill -9 ${LS_PID}
  fi
  sleep 5
done

echo "shutdown complete"
