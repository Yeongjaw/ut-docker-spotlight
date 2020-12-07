#!/usr/bin/env bash

# Source variables from the versionfile
. version; export $(cut -d= -f1 version)

# Build image from the local dicrectory
docker build . \
  -t utexas-glib-it-docker-local.jfrog.io/${NAME}-${RELEASE}:${MAJOR}.${MINOR}.${HOTFIX} \
  --cache-from=e39adf175625 
# 3a3645e9e524
# 12e97ac93647
# Uncomment the following to push image to artifactory repository
# docker push utexas-glib-it-docker-local.jfrog.io/${NAME}-${RELEASE}:${MAJOR}.${MINOR}.${HOTFIX}
