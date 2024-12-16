#!/bin/bash
set -m

instances=2
channels=1
render=false

if [ $# -eq 0 ]
then
  echo "** `date` ** using default [ ${channels}-channel(s) ] with [ ${instances}-instance(s) ] per channel"
else

  # number of instances per channel
  # each channel to have 2 instances = 4 connections
  while getopts ":c:i:r" opt; do
    case ${opt} in
      c)
        channels=${OPTARG}
        ;;
      i)
        instances=${OPTARG}
        ;;
      r)
        render="true"
        ;;
      :)
        echo "Option -${OPTARG} requires an argument."
        exit 1
        ;;
      ?)
        echo "Invalid argument -${OPTARG}"
        exit 1
        ;;
    esac
  done
  echo "** `date` ** using [ ${channels}-channel(s) ] with [ ${instances}-instance(s) ] per channel"
fi

for channel in $(seq 1 $channels)
do
  for instance in $(seq 1 $instances)
  do

    echo "connecting ... channel = [ ${channel} ] instance = ${instance}"

    /app/run-fake.sh "${channel}" "${instance}"

    if [ ${render} == "true" ];then
      echo "connecting render client to channel = [ ${channel} ]"
      sleep 15

      LS_CONNECTION_ID=`cat /home/${ENV_LS_CHANNEL_ID}-${channel}-${instance}.fake.log | grep -E "^Connection '([0-9a-f]{1,32})' state is connected.$" | sed "s/^Connection '\(.*\)' state is connected.$/\1/"`
      /app/run-render.sh "${channel}" "${instance}" "${LS_CONNECTION_ID}"
    fi

    echo "connected ... ${LS_HOME_URL}gatewayurl=${ENV_LS_MEDIA_GATEWAY_URL}&sharedsecret=${ENV_LS_MEDIA_GATEWAY_SECRET}&application=${ENV_LS_APPLICATION_ID}&channel=myChannel-${channel}"
    sleep 5
  done

done

tail -f /dev/null
