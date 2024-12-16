#!/bin/bash

# staging
# export AWS_PROFILE=staging
# aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 082320812392.dkr.ecr.eu-west-2.amazonaws.com

# dev
export AWS_PROFILE=dev
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 635667282645.dkr.ecr.eu-west-2.amazonaws.com
docker push 635667282645.dkr.ecr.eu-west-2.amazonaws.com/liveswitch/load-testing:1.13

# docker push "${LS_IMAGE_NAME}:${LS_VERSION}"