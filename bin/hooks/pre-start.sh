#!/bin/sh
# `pwd` should be /opt/man_api
APP_NAME="man_api"

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "Elixir.Man.ReleaseTasks" migrate!
fi;
