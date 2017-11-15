FROM edenlabllc/alpine-elixir

MAINTAINER Nebo#15 support@nebo15.com

# Configure environment variables and other settings
ENV MIX_ENV=prod \
    APP_NAME=man_api \
    APP_PORT=4000

WORKDIR ${HOME}

# Install wkhtmltopdf
RUN apk add --update --no-cache \
      libgcc \
      libstdc++ \
      libx11 \
      glib \
      libxrender \
      libxext \
      libintl \
      ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family \
      fontconfig \
      dbus

# Install build deps
RUN apk add --update --no-cache --virtual .build-deps \
  libcrypto1.0 \
  libssl1.0 \
  make \
  g++

COPY rel/deps/wkhtmltopdf /bin
RUN chmod +x /bin/wkhtmltopdf

# Install and compile project dependencies
COPY mix.* ./
RUN mix do deps.get, deps.compile

# Add project sources
COPY . .

# Compile project for Erlang VM
RUN mix do compile, release --verbose

# Reduce container size
RUN apk del  --no-cache .build-deps

# Move release to /opt/$APP_NAME
RUN \
    mkdir -p $HOME/priv && \
    mkdir -p /opt/$APP_NAME/log && \
    mkdir -p /var/log && \
    mkdir -p /opt/$APP_NAME/priv && \
    mkdir -p /opt/$APP_NAME/hooks && \
    mkdir -p /opt/$APP_NAME/uploads && \
    cp -R $HOME/priv /opt/$APP_NAME/ && \
    cp -R $HOME/bin/hooks /opt/$APP_NAME/ && \
    APP_TARBALL=$(find $HOME/_build/$MIX_ENV/rel/$APP_NAME/releases -maxdepth 2 -name ${APP_NAME}.tar.gz) && \
    cp $APP_TARBALL /opt/$APP_NAME/ && \
    cd /opt/$APP_NAME && \
    tar -xzf $APP_NAME.tar.gz && \
    rm $APP_NAME.tar.gz && \
    rm -rf /opt/app/* && \
    chmod -R 777 $HOME && \
    chmod -R 777 /opt/$APP_NAME && \
    chmod -R 777 /var/log

# Change user to "default"
USER default

# Allow to read ENV vars for mix configs
ENV REPLACE_OS_VARS=true

# Exposes this port from the docker container to the host machine
EXPOSE ${APP_PORT}

# Change workdir to a released directory
WORKDIR /opt

# Pre-run hook that allows you to add initialization scripts.
# All Docker hooks should be located in bin/hooks directory.
RUN $APP_NAME/hooks/pre-run.sh

# The command to run when this image starts up.
# To run migrations on start set DB_MIGRATE=true env when starting container.
CMD $APP_NAME/bin/$APP_NAME foreground
