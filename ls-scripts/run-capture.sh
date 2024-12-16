#!/bin/bash

#docker run --rm
/app/lsconnect \
 capture \
 --gateway-url "${ENV_LS_MEDIA_GATEWAY_URL}" \
 --shared-secret "${ENV_LS_MEDIA_GATEWAY_SECRET}" \
 --application-id "${ENV_LS_APPLICATION_ID}" \
 --channel-id "${ENV_LS_CHANNEL_ID}" \
 --audio-pipe my-audio-pipe \
 --video-pipe my-video-pipe \
 --video-width 1920 \
 --video-height 1080 \
