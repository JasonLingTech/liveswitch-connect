channel=$1
instance=$2

/app/lsconnect \
 fake \
 --gateway-url "${ENV_LS_MEDIA_GATEWAY_URL}" \
 --shared-secret "${ENV_LS_MEDIA_GATEWAY_SECRET}" \
 --application-id "${ENV_LS_APPLICATION_ID}" \
 --channel-id "${ENV_LS_CHANNEL_ID}-${channel}" \
 --video-frame-rate 30 >>/home/${ENV_LS_CHANNEL_ID}-${channel}-${instance}.fake.log 2>&1 &
