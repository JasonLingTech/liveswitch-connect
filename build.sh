#!/bin/bash

IMAGE_TIMEZONE=${IMAGE_TIMEZONE:-"Europe/London"}
LS_VERSION_UNDER_TEST="1.13"
#LS_IMAGE_NAME=${LS_IMAGE_NAME:-"635667282645.dkr.ecr.eu-west-2.amazonaws.com/liveswitch/load-testing"}
LS_IMAGE_NAME=${LS_IMAGE_NAME:-"ummanu-lsconnect"}

pushImage=0

case ${LS_ENV} in
  "dev")
    pushImage=0
    echo "setting environment to ${LS_ENV}"
    set -a && source .dev.env && set +a
    ;;
  "femi")
    pushImage=0
    echo "setting environment to ${LS_ENV}"
    set -a && source .femi.env && set +a
    ;;
  "staging")
    pushImage=1
    echo "setting environment to ${LS_ENV}"
    set -a && source .staging.env && set +a
    ;;
  "prod")
    pushImage=1
    echo "setting environment to ${LS_ENV}"
    set -a && source .prod.env && set +a
    ;;
  "")
  echo "environment variable [ LS_ENV ] not set (dev, staging, prod) "
  exit 1
  ;;
esac

#LS_VERSION_UNDER_TEST="${LS_ENV}.1.13"

# Remove the image so we have a clean start
# and environment variables are as expected
docker rmi "${LS_IMAGE_NAME}:${LS_VERSION_UNDER_TEST}"

# Docker build command line
#docker build \
docker build --no-cache \
  --build-arg IMAGE_TIMEZONE=${IMAGE_TIMEZONE} \
  --build-arg LS_MEDIA_GATEWAY_URL=${LS_MEDIA_GATEWAY_URL} \
  --build-arg LS_MEDIA_GATEWAY_SECRET=${LS_MEDIA_GATEWAY_SECRET} \
  --build-arg LS_API_KEY=${LS_API_KEY} \
  --build-arg LS_APPLICATION_ID=${LS_APPLICATION_ID} \
  --build-arg LS_CHANNEL_ID=${LS_CHANNEL_ID} \
  -t "${LS_IMAGE_NAME}:${LS_VERSION_UNDER_TEST}" .

# staging
# export AWS_PROFILE=staging
# aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 082320812392.dkr.ecr.eu-west-2.amazonaws.com

# dev
# export AWS_PROFILE=dev
# aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 635667282645.dkr.ecr.eu-west-2.amazonaws.com
# docker push 635667282645.dkr.ecr.eu-west-2.amazonaws.com/liveswitch/load-testing:1.13

# docker push "${LS_IMAGE_NAME}:${LS_VERSION}"
