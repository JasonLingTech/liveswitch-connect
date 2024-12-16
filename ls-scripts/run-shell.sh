#!/bin/bash

#docker run --rm
/app/lsconnect \
 shell \
 --gateway-url "${ENV_LS_MEDIA_GATEWAY_URL}" \
 --shared-secret "${ENV_LS_MEDIA_GATEWAY_SECRET}" \
 --application-id "${ENV_LS_APPLICATION_ID}"
