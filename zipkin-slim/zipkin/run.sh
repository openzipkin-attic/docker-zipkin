#!/bin/sh

if [ -f ".${STORAGE_TYPE}_profile" ]; then
  source ${PWD}/.${STORAGE_TYPE}_profile
fi

exec java ${JAVA_OPTS} -cp $(cat /zipkin/classpath) zipkin.server.ZipkinServer
