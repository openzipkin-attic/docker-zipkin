#!/bin/sh

if [ -f ".${STORAGE_TYPE}_profile" ]; then
  source ${PWD}/.${STORAGE_TYPE}_profile
fi

exec java ${MODULE_OPTS} ${JAVA_OPTS} -cp . org.springframework.boot.loader.PropertiesLauncher "$@"
