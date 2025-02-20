#!/bin/bash
set -m

instances=2
channels=1
render=false
channelTime=1800

if [ $# -eq 0 ]
then
  echo "** `date` **"
  echo "** using defaults **"
  echo "** channels = [ ${channels} ] **"
  echo "** instances per channel = [ ${instances} ] **"
  echo "** render incomming instance = [ ${render} ] **"
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
  echo "**********************************"
  echo "** `date` **"
  echo ""
  echo "** channels = [ ${channels} ]"
  echo "** instances per channel = [ ${instances} ]"
  echo "** render incomming instance = [ ${render} ]"
  echo "**********************************"
  echo ""
  sleep 2
fi

for channel in $(seq 1 $channels)
do
  echo "********************************"
  for instance in $(seq 1 $instances)
  do
    echo "--------------------------------"
    echo "- creating channel [ ${channel} ] with instance [ ${instance} ]"

    /app/lsconnect \
    fake \
    --gateway-url "${ENV_LS_MEDIA_GATEWAY_URL}" \
    --shared-secret "${ENV_LS_MEDIA_GATEWAY_SECRET}" \
    --application-id "${ENV_LS_APPLICATION_ID}" \
    --channel-id "${ENV_LS_CHANNEL_ID}-${channel}" \
    --video-frame-rate 30 >>/home/${ENV_LS_CHANNEL_ID}-${channel}-${instance}.fake.log 2>&1 &

    if [ ${render} == "true" ];then
      echo "- attempting to connect a render client to channel = [ ${channel} ] and instance = [ ${instance} ] ... "
      sleep 2

      LS_CONNECTION_ID=""
      while [ -z ${LS_CONNECTION_ID} ]
      do
        LS_CONNECTION_ID=`cat /home/${ENV_LS_CHANNEL_ID}-${channel}-${instance}.fake.log | grep -E "^Connection '([0-9a-f]{1,32})' state is connected.$" | sed "s/^Connection '\(.*\)' state is connected.$/\1/"`
        echo "- `date` --- connection id = [ ${LS_CONNECTION_ID} ]"
        sleep 1
      done

      /app/lsconnect \
      render \
      --gateway-url "${ENV_LS_MEDIA_GATEWAY_URL}" \
      --shared-secret "${ENV_LS_MEDIA_GATEWAY_SECRET}" \
      --application-id "${ENV_LS_APPLICATION_ID}" \
      --channel-id "myChannel-${channel}" \
      --connection-id "${LS_CONNECTION_ID}" \
      --audio-pipe my-audio-pipe \
      --video-pipe my-video-pipe \
      --video-width 1280 \
      --video-height 720 >>/home/${ENV_LS_CHANNEL_ID}-${channel}-${instance}.render.log 2>&1 &

      echo "... render client connected to channel [ ${ENV_LS_CHANNEL_ID}-${channel} ] and instance [ ${instance} ] with connection id [ ${LS_CONNECTION_ID} ]"

    fi

    echo "--------------------------------"

    echo "connected ... ${LS_HOME_URL}gatewayurl=${ENV_LS_MEDIA_GATEWAY_URL}&sharedsecret=${ENV_LS_MEDIA_GATEWAY_SECRET}&application=${ENV_LS_APPLICATION_ID}&channel=myChannel-${channel}"

  done
  echo "********************************"
  echo ""
  sleep 2
done

tail -f /dev/null
