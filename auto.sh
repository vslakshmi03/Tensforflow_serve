#!/bin/bash

set -eu

EPOCH="$(date +%s)"

# Logging functions
_info () { echo -e "\n\033[1;92mINFO: ${1}\033[0m\n"; }
_err () { echo -e "\n\033[1;91mERROR: ${1}\033[0m\n"; }

# Cleanup function
_cleanup () {
  docker rmi tensflow_$EPOCH
  rm -f ./Dockerfile_model
  echo
}

# Check if root or sudo
[[ "$EUID" -ne 0 ]] && { _err "The script must be executed as root"; exit 1; }

# Use the script directory even if running from other dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" && cd $DIR

# Check if python file exist
[[ -f "./tensorflow-serve.py" ]] || { _err "Can't find tensorflow-serve.py file. Create it first"; exit 1; }

_info "Creating Dockerfile"
cat << EOF > Dockerfile_model
FROM python:2.7.17-slim
RUN pip install -qq --upgrade pip && \
    pip install -qq --no-cache-dir tensorflow==1.12 tensorflow_hub==0.2.0
WORKDIR /app
COPY ./tensorflow-serve.py ./
VOLUME /home/tfserving
EOF
ls -lah Dockerfile_model

_info "Building docker image"
docker build -f Dockerfile_model -t tensflow_$EPOCH . || \
    { _err "Cannot build docker image"; _cleanup; exit 1; }

_info "Running model directory generation"
docker run --rm -i -v '/home/tfserving:/home/tfserving' tensflow_$EPOCH python tensorflow-serve.py || \
    { _err "Model directory generation failed"; _cleanup; exit 1; }

_cleanup

_info "Remove python base image"
docker rmi python:2.7.17-slim

_info "All done"
