#!/bin/sh
# `pwd` should be /opt/man
APP_NAME="man"

if [ "${DB_MIGRATE}" == "true" ]; then
  echo "[WARNING] Migrating database!"
  ./bin/$APP_NAME command "Elixir.Postboy.ReleaseTasks" migrate!
fi;
