#!/bin/bash

#docker run --rm
/app/lsconnect \
 log \
 --log-level fatal \
 --gateway-url "${ENV_LS_MEDIA_GATEWAY_URL}" \
 --shared-secret "${ENV_LS_MEDIA_GATEWAY_SECRET}" \
 --application-id "${ENV_LS_APPLICATION_ID}" \
 --channel-id "${ENV_LS_CHANNEL_ID}" \
 --connection-id "${CLI_CONNECTION_ID}"
