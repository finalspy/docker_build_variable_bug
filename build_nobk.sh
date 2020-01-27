!#/bin/sh
export DOCKER_BUILDKIT=0 \
&& docker build --no-cache -t bug:nobk -f Dockerfile_bugvar . \
&& docker run bug:nobk
