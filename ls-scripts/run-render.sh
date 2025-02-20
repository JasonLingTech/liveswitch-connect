channel=$1
instance=$2
LS_CONNECTION_ID=$3

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
