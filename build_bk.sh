#!/bin/sh
export DOCKER_BUILDKIT=1 \
&& docker build --no-cache -t bug:bk -f Dockerfile_bugvar . \
&& docker run bug:bk
