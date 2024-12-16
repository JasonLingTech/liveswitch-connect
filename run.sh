#!/bin/bash

clear

LS_CONTAINER_NAME=${LS_CONTAINER_NAME:-"liveswitch-connect"}
LS_IMAGE_NAME=${LS_IMAGE_NAME:-"ummanu-lsconnect"}
LS_VERSION_UNDER_TEST="1.13"

docker run --rm -d --name ${LS_CONTAINER_NAME} ${LS_IMAGE_NAME}:${LS_VERSION_UNDER_TEST} $@
